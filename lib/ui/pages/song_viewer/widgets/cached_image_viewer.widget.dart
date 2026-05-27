import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/infrastructure/song/providers/sync.providers.dart';
import 'package:songbook/ui/pages/song_viewer/widgets/zoomable_image_viewer.widget.dart';

/// Résout des URLs d'images vers leurs fichiers locaux (téléchargement et mise
/// en cache à la demande) puis les affiche via [ZoomableImageViewer].
///
/// Le cache n'a pas de péremption : une image déjà présente localement n'est
/// jamais re-téléchargée. Sur le web, le cache renvoie l'URL telle quelle et
/// l'affichage se fait directement via le réseau.
class CachedImageViewer extends ConsumerStatefulWidget {
  final String songId;
  final List<String> imageUrls;

  const CachedImageViewer({
    super.key,
    required this.songId,
    required this.imageUrls,
  });

  @override
  ConsumerState<CachedImageViewer> createState() => _CachedImageViewerState();
}

class _CachedImageViewerState extends ConsumerState<CachedImageViewer> {
  late Future<List<String>> _pathsFuture;

  @override
  void initState() {
    super.initState();
    _pathsFuture = _resolvePaths();
  }

  @override
  void didUpdateWidget(CachedImageViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.songId != widget.songId ||
        !listEquals(oldWidget.imageUrls, widget.imageUrls)) {
      _pathsFuture = _resolvePaths();
    }
  }

  Future<List<String>> _resolvePaths() async {
    final cache = await ref.read(resourceCacheRepositoryProvider.future);
    final songId = UuidValue.parse(widget.songId);
    return Future.wait(
      widget.imageUrls.map((url) => cache.getCachedResource(url, songId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _pathsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null) {
          return _buildError();
        }
        return ZoomableImageViewer(imagePaths: snapshot.data!);
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
            'Impossible de télécharger les partitions',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => setState(() {
              _pathsFuture = _resolvePaths();
            }),
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}
