import 'package:songbook/core/domain/model/remote_song.dart';
import 'package:songbook/core/domain/model/resource.dart';
import 'package:songbook/core/domain/model/song.dart';
import 'package:songbook/core/domain/model/sync_diff.dart';
import 'package:songbook/core/domain/services/song.repository.dart';

/// Use case pour appliquer les actions de synchronisation de la liste de chants.
///
/// Ce use case prend un [SyncDiff] et réconcilie la base locale avec le
/// serveur, **sans télécharger les ressources** : seules les métadonnées et les
/// URLs des ressources sont persistées. Les images/PDF sont mis en cache à la
/// demande lors de l'affichage.
/// - Supprime les songs disparus du serveur
/// - Met à jour les songs modifiés
/// - Ajoute les nouveaux songs
class ExecuteSyncUseCase {
  final SongRepository _songRepository;

  ExecuteSyncUseCase(this._songRepository);

  /// Applique la synchronisation décrite par [diff].
  Future<void> execute(SyncDiff diff) async {
    for (final toDelete in diff.toDelete) {
      await _songRepository.deleteSong(toDelete.localSong.id);
    }

    for (final toUpdate in diff.toUpdate) {
      await _songRepository.updateSong(_songFromRemote(toUpdate.remoteSong));
    }

    for (final toAdd in diff.toAdd) {
      await _songRepository.addSong(_songFromRemote(toAdd.remoteSong));
    }
  }

  /// Crée un [Song] local depuis un [RemoteSong] en conservant les URLs des
  /// ressources (aucun téléchargement).
  Song _songFromRemote(RemoteSong remote) {
    return Song(
      id: remote.id,
      code: remote.code,
      name: remote.name,
      updatedAt: remote.updatedAt,
      resources: remote.resources.map(_resourceFromRemote).toList(),
    );
  }

  Resource _resourceFromRemote(RemoteResource remote) {
    return switch (remote) {
      RemoteImageResource() => ImageResource(
        id: remote.id,
        name: remote.name,
        imageUrls: remote.imageUrls,
      ),
      RemotePdfResource() => PdfResource(
        id: remote.id,
        name: remote.name,
        pdfUrl: remote.pdfUrl,
      ),
    };
  }
}
