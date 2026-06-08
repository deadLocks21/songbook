import 'package:songbook/core/domain/model/remote_song.dart';
import 'package:songbook/core/domain/model/song.dart';
import 'package:songbook/core/domain/model/sync_diff.dart';
import 'package:songbook/core/domain/services/song.repository.dart';

/// Use case pour calculer les différences entre les données distantes et locales.
///
/// Ce use case compare les songs disponibles sur le serveur distant avec ceux
/// présents localement, et retourne un [SyncDiff] décrivant les actions à effectuer.
class ComputeSyncDiffUseCase {
  final SongRepository _localRepository;

  ComputeSyncDiffUseCase(this._localRepository);

  /// Exécute le calcul des différences.
  ///
  /// [remoteSongs] est la liste des chants telle que renvoyée par le serveur ;
  /// elle est récupérée en amont (cf. [SyncService]) afin de pouvoir être
  /// réutilisée pour le cache des partitions.
  /// Retourne un [SyncDiff] contenant les songs à ajouter, mettre à jour et supprimer.
  Future<SyncDiff> execute(List<RemoteSong> remoteSongs) async {
    final localSongs = await _localRepository.getAllSongs();

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
      } else if (remote.updatedAt.isAfter(local.updatedAt) ||
          _resourcesDiffer(local, remote)) {
        // Song existant mais modifié sur le serveur : soit une version plus
        // récente, soit un changement de ses ressources (ajout/suppression) qui
        // ne bouge pas forcément `updatedAt` du chant porteur.
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

  /// Vrai si l'ensemble des ressources (identifiées par leur UUID) diffère entre
  /// la version locale et la version distante du chant.
  bool _resourcesDiffer(Song local, RemoteSong remote) {
    final localIds = {for (final r in local.resources) r.id};
    final remoteIds = {for (final r in remote.resources) r.id};
    return localIds.length != remoteIds.length ||
        !localIds.containsAll(remoteIds);
  }
}
