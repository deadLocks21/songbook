import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/domain/model/recueil.dart';
import 'package:songbook/core/domain/model/remote_song.dart';
import 'package:songbook/core/domain/services/remote_recueil.repository.dart';
import 'package:songbook/infrastructure/recueil/dio.remote_recueil.repository.dart';
import 'package:songbook/infrastructure/recueil/in_memory.remote_recueil.repository.dart';
import 'package:songbook/infrastructure/settings/providers/settings.service_provider.dart';
import 'package:songbook/infrastructure/song/providers/sync.providers.dart';

part 'recueil.providers.g.dart';

/// Provider pour le repository des recueils distants.
/// Utilise l'implémentation en mémoire sur le web (CORS).
@riverpod
RemoteRecueilRepository remoteRecueilRepository(Ref ref) {
  if (kIsWeb) {
    return InMemoryRemoteRecueilRepository();
  }
  return DioRemoteRecueilRepository(ref.watch(dioProvider));
}

/// Liste des recueils disponibles sur le serveur configuré.
///
/// Nécessite l'authentification (JWT injecté par l'intercepteur Dio) : à
/// n'utiliser qu'après connexion.
@riverpod
Future<List<Recueil>> availableRecueils(Ref ref) async {
  final backendUrl = await ref.watch(backendUrlProvider.future);
  if (backendUrl == null || backendUrl.isEmpty) {
    return const [];
  }
  return ref.watch(remoteRecueilRepositoryProvider).fetchRecueils(backendUrl);
}

/// Catalogue complet des chants distants (un seul appel `/api/songs`).
///
/// Mémoïsé : sert de source pour l'appartenance aux recueils, les totaux et les
/// URLs des partitions, sans refaire d'appel réseau à chaque recalcul des
/// statistiques de téléchargement.
@riverpod
Future<List<RemoteSong>> remoteSongCatalog(Ref ref) async {
  final backendUrl = await ref.watch(backendUrlProvider.future);
  if (backendUrl == null || backendUrl.isEmpty) {
    return const [];
  }
  return ref.watch(remoteSongRepositoryProvider).fetchSongs(backendUrl);
}

/// Statistiques d'un recueil : nombre total de chants et nombre de chants déjà
/// téléchargés localement (toutes leurs partitions en cache).
typedef RecueilSongStats = ({int total, int downloaded});

/// Statistiques par code de recueil : total (depuis le catalogue mémoïsé) et
/// nombre de chants déjà téléchargés (présence des partitions sur le disque).
///
/// Seule la partie disque est recalculée ici ; le catalogue réseau étant
/// mémoïsé, invalider ce provider (ex. à l'ouverture des réglages) ne relance
/// que les vérifications de fichiers locaux.
@riverpod
Future<Map<String, RecueilSongStats>> recueilSongStats(Ref ref) async {
  final songs = await ref.watch(remoteSongCatalogProvider.future);
  final cache = await ref.watch(resourceCacheRepositoryProvider.future);

  final totals = <String, int>{};
  final downloaded = <String, int>{};

  for (final song in songs) {
    final urls = _resourceUrls(song);
    // Un chant est « téléchargé » quand toutes ses partitions sont en cache.
    // Un chant sans ressource est trivialement disponible.
    var isDownloaded = true;
    for (final url in urls) {
      if (!await cache.isResourceCached(url, song.id)) {
        isDownloaded = false;
        break;
      }
    }
    for (final code in song.recueils) {
      totals[code] = (totals[code] ?? 0) + 1;
      if (isDownloaded) {
        downloaded[code] = (downloaded[code] ?? 0) + 1;
      }
    }
  }

  return {
    for (final code in totals.keys)
      code: (total: totals[code]!, downloaded: downloaded[code] ?? 0),
  };
}

/// URLs de toutes les partitions (images/PDF) d'un chant distant.
List<String> _resourceUrls(RemoteSong song) {
  return [
    for (final resource in song.resources)
      ...switch (resource) {
        RemoteImageResource(:final imageUrls) => imageUrls,
        RemotePdfResource(:final pdfUrl) => [pdfUrl],
      },
  ];
}
