import 'package:songbook/core/application/usecases/compute_sync_diff.usecase.dart';
import 'package:songbook/core/application/usecases/execute_sync.usecase.dart';
import 'package:songbook/core/domain/model/remote_song.dart';
import 'package:songbook/core/domain/services/remote_song.repository.dart';
import 'package:songbook/core/domain/services/song.repository.dart';

/// Service de synchronisation de la **liste** des chants.
///
/// Réconcilie la base locale avec le serveur (ajouts / mises à jour /
/// suppressions). Le téléchargement des partitions est laissé à l'appelant
/// (cf. `CacheRecueilPartitionsUseCase`) : seuls les recueils sélectionnés sont
/// mis en cache, les autres restent téléchargés à la demande à l'affichage.
class SyncService {
  final RemoteSongRepository _remoteSongRepository;
  final ComputeSyncDiffUseCase _computeSyncDiff;
  final ExecuteSyncUseCase _executeSync;

  SyncService(
    SongRepository songRepository,
    RemoteSongRepository remoteSongRepository,
  )   : _remoteSongRepository = remoteSongRepository,
        _computeSyncDiff = ComputeSyncDiffUseCase(songRepository),
        _executeSync = ExecuteSyncUseCase(songRepository);

  /// Synchronise la liste locale des chants avec le serveur distant.
  ///
  /// Retourne la liste des chants distants telle que reçue du serveur, afin que
  /// l'appelant puisse mettre en cache les partitions des recueils choisis sans
  /// refaire d'appel réseau.
  Future<List<RemoteSong>> syncSongList(String baseUrl) async {
    final remoteSongs = await _remoteSongRepository.fetchSongs(baseUrl);
    final diff = await _computeSyncDiff.execute(remoteSongs);
    await _executeSync.execute(diff);
    return remoteSongs;
  }
}
