import 'package:songbook/core/domain/model/remote_song.dart';
import 'package:songbook/core/domain/model/resource.dart';
import 'package:songbook/core/domain/model/song.dart';
import 'package:songbook/core/domain/model/sync_diff.dart';
import 'package:songbook/core/domain/services/remote_resource.repository.dart';
import 'package:songbook/core/domain/services/song.repository.dart';

/// Use case pour exécuter les actions de synchronisation.
///
/// Ce use case prend un [SyncDiff] et effectue les opérations nécessaires :
/// - Supprime les songs disparus du serveur
/// - Met à jour les songs modifiés (télécharge les nouvelles ressources)
/// - Ajoute les nouveaux songs (télécharge les ressources)
class ExecuteSyncUseCase {
  final SongRepository _songRepository;
  final RemoteResourceRepository _resourceRepository;

  ExecuteSyncUseCase(this._songRepository, this._resourceRepository);

  /// Exécute la synchronisation.
  ///
  /// [diff] contient les actions à effectuer (ajout, mise à jour, suppression).
  /// [onProgress] callback optionnel pour rapporter la progression (0.0 à 1.0).
  Future<void> execute(
    SyncDiff diff, {
    void Function(double progress)? onProgress,
  }) async {
    // Calculer le nombre total d'opérations pour la progression
    final totalOperations =
        diff.toDelete.length + diff.toUpdate.length + diff.toAdd.length;
    if (totalOperations == 0) {
      onProgress?.call(1.0);
      return;
    }

    var completedOperations = 0;
    onProgress?.call(0.0);

    // 1. Supprimer les songs disparus du serveur
    for (final toDelete in diff.toDelete) {
      await _resourceRepository.deleteResourcesForSong(toDelete.localSong.id);
      await _songRepository.deleteSong(toDelete.localSong.id);
      completedOperations++;
      onProgress?.call(completedOperations / totalOperations);
    }

    // 2. Mettre à jour les songs modifiés
    // (supprimer les anciennes ressources, télécharger les nouvelles, UPDATE en base)
    for (final toUpdate in diff.toUpdate) {
      await _resourceRepository.deleteResourcesForSong(toUpdate.localSong.id);
      final localResources = await _downloadResources(toUpdate.remoteSong);
      final updatedSong = _createSongFromRemote(
        toUpdate.remoteSong,
        localResources,
      );
      await _songRepository.updateSong(updatedSong);
      completedOperations++;
      onProgress?.call(completedOperations / totalOperations);
    }

    // 3. Ajouter les nouveaux songs
    for (final toAdd in diff.toAdd) {
      final localResources = await _downloadResources(toAdd.remoteSong);
      final newSong = _createSongFromRemote(toAdd.remoteSong, localResources);
      await _songRepository.addSong(newSong);
      completedOperations++;
      onProgress?.call(completedOperations / totalOperations);
    }

    onProgress?.call(1.0);
  }

  /// Télécharge toutes les ressources d'un song distant.
  /// Retourne les ressources avec les chemins locaux.
  Future<List<Resource>> _downloadResources(RemoteSong remoteSong) async {
    final resources = <Resource>[];

    for (final remoteResource in remoteSong.resources) {
      switch (remoteResource) {
        case RemoteImageResource():
          final localPaths = <String>[];
          for (var i = 0; i < remoteResource.imageUrls.length; i++) {
            final url = remoteResource.imageUrls[i];
            final filename = _extractFilename(url, 'image_$i');
            final localPath = await _resourceRepository.downloadResource(
              url,
              remoteSong.id,
              filename,
            );
            localPaths.add(localPath);
          }
          resources.add(
            ImageResource(
              id: remoteResource.id,
              name: remoteResource.name,
              imagePaths: localPaths,
            ),
          );

        case RemotePdfResource():
          final filename = _extractFilename(
            remoteResource.pdfUrl,
            'document.pdf',
          );
          final localPath = await _resourceRepository.downloadResource(
            remoteResource.pdfUrl,
            remoteSong.id,
            filename,
          );
          resources.add(
            PdfResource(
              id: remoteResource.id,
              name: remoteResource.name,
              pdfPath: localPath,
            ),
          );
      }
    }

    return resources;
  }

  /// Crée un Song domain depuis un RemoteSong et ses ressources locales.
  Song _createSongFromRemote(RemoteSong remote, List<Resource> localResources) {
    return Song(
      id: remote.id,
      code: remote.code,
      name: remote.name,
      updatedAt: remote.updatedAt,
      resources: localResources,
    );
  }

  /// Extrait le nom de fichier depuis une URL, ou utilise un nom par défaut.
  String _extractFilename(String url, String defaultName) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        final lastSegment = pathSegments.last;
        if (lastSegment.isNotEmpty && lastSegment.contains('.')) {
          return lastSegment;
        }
      }
    } catch (_) {
      // En cas d'erreur de parsing, utiliser le nom par défaut
    }
    return defaultName;
  }
}
