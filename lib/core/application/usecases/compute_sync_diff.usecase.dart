import 'package:songbook/core/domain/model/sync_diff.dart';
import 'package:songbook/core/domain/services/remote_song.repository.dart';
import 'package:songbook/core/domain/services/song.repository.dart';

/// Use case pour calculer les différences entre les données distantes et locales.
///
/// Ce use case compare les songs disponibles sur le serveur distant avec ceux
/// présents localement, et retourne un [SyncDiff] décrivant les actions à effectuer.
class ComputeSyncDiffUseCase {
  final SongRepository _localRepository;
  final RemoteSongRepository _remoteRepository;

  ComputeSyncDiffUseCase(this._localRepository, this._remoteRepository);

  /// Exécute le calcul des différences.
  ///
  /// [baseUrl] est l'URL de base de l'API distante.
  /// Retourne un [SyncDiff] contenant les songs à ajouter, mettre à jour et supprimer.
  Future<SyncDiff> execute(String baseUrl) async {
    final localSongs = await _localRepository.getAllSongs();
    final remoteSongs = await _remoteRepository.fetchSongs(baseUrl);

    final localById = {for (final s in localSongs) s.id: s};
    final remoteById = {for (final s in remoteSongs) s.id: s};

    final toAdd = <SongToAdd>[];
    final toUpdate = <SongToUpdate>[];
    final toDelete = <SongToDelete>[];

    // Songs à ajouter ou mettre à jour
    for (final remote in remoteSongs) {
      final local = localById[remote.id];
      if (local == null) {
        // Song nouveau, absent localement
        toAdd.add(SongToAdd(remoteSong: remote));
      } else if (remote.updatedAt.isAfter(local.updatedAt)) {
        // Song existant mais avec une version plus récente sur le serveur
        toUpdate.add(SongToUpdate(localSong: local, remoteSong: remote));
      }
      // Sinon, le song local est à jour, rien à faire
    }

    // Songs à supprimer (présents localement mais disparus du serveur)
    for (final local in localSongs) {
      if (!remoteById.containsKey(local.id)) {
        toDelete.add(SongToDelete(localSong: local));
      }
    }

    return SyncDiff(toAdd: toAdd, toUpdate: toUpdate, toDelete: toDelete);
  }
}
