import 'dart:io';

import 'package:chord_pro/chord_pro.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/infrastructure/logger/providers/logger.service_provider.dart';
import 'package:songbook/infrastructure/song/providers/sync.providers.dart';
import 'package:songbook/ui/pages/chord_pro_viewer/chord_pro_viewer.page.dart';

/// Résout l'URL d'un fichier ChordPro vers son contenu (téléchargement et mise
/// en cache à la demande, exactement comme `CachedImageViewer` pour les
/// partitions images), le parse, puis l'affiche via [ChordProView] transposé de
/// [semitones] demi-tons.
///
/// Pas de Scaffold : le widget s'intègre dans la visionneuse de chant
/// ([SongViewerPage]), qui porte l'AppBar et le contrôle de transposition.
///
/// Le cache n'a pas de péremption : un fichier déjà présent localement n'est
/// jamais re-téléchargé. Sur le web, le cache renvoie l'URL telle quelle et le
/// contenu est récupéré directement via le réseau (avec le JWT).
class CachedChordProViewer extends ConsumerStatefulWidget {
  final String songId;
  final String chordProUrl;
  final int semitones;

  const CachedChordProViewer({
    super.key,
    required this.songId,
    required this.chordProUrl,
    this.semitones = 0,
  });

  @override
  ConsumerState<CachedChordProViewer> createState() =>
      _CachedChordProViewerState();
}

class _CachedChordProViewerState extends ConsumerState<CachedChordProViewer> {
  late Future<Song> _songFuture;

  @override
  void initState() {
    super.initState();
    _songFuture = _resolveSong();
  }

  @override
  void didUpdateWidget(CachedChordProViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // La transposition ne change pas la source : on ne recharge que si le chant
    // ou l'URL change (le rebuild applique le nouveau [semitones] au chant déjà
    // parsé).
    if (oldWidget.songId != widget.songId ||
        oldWidget.chordProUrl != widget.chordProUrl) {
      _songFuture = _resolveSong();
    }
  }

  Future<Song> _resolveSong() async {
    try {
      final cache = await ref.read(resourceCacheRepositoryProvider.future);
      final songId = UuidValue.parse(widget.songId);
      final pathOrUrl = await cache.getCachedResource(
        widget.chordProUrl,
        songId,
      );

      final String source;
      // Sur le web (ou si le cache renvoie une URL), on récupère le texte via
      // le réseau ; sinon on lit le fichier mis en cache sur disque.
      if (kIsWeb ||
          pathOrUrl.startsWith('http://') ||
          pathOrUrl.startsWith('https://')) {
        final dio = ref.read(dioProvider);
        final response = await dio.get<String>(
          pathOrUrl,
          options: Options(responseType: ResponseType.plain),
        );
        source = response.data ?? '';
      } else {
        source = await File(pathOrUrl).readAsString();
      }
      return ChordPro.parseSong(source);
    } catch (e, stack) {
      // L'erreur serait sinon avalée par le FutureBuilder : on la journalise
      // pour pouvoir diagnostiquer (statut HTTP 404/502, encodage du fichier,
      // connexion…). Puis on la re-lève pour conserver l'UI d'erreur.
      ref
          .read(loggerProvider)
          .error(
            'chordpro.download_failed',
            attrs: {'songId': widget.songId, 'url': widget.chordProUrl},
            error: e,
            stack: stack,
          );
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Song>(
      future: _songFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null) {
          return _buildError();
        }
        final base = snapshot.data!;
        final song = widget.semitones == 0
            ? base
            : base.transposed(widget.semitones);
        return ChordProView(song: song);
      },
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 48),
          const SizedBox(height: 16),
          Text(
            'Impossible de télécharger le fichier ChordPro',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => setState(() {
              _songFuture = _resolveSong();
            }),
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}
