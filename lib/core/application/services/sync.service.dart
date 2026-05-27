import 'package:songbook/core/application/usecases/compute_sync_diff.usecase.dart';
import 'package:songbook/core/application/usecases/execute_sync.usecase.dart';
import 'package:songbook/core/domain/services/remote_song.repository.dart';
import 'package:songbook/core/domain/services/song.repository.dart';

/// Service de synchronisation de la **liste** des chants.
///
/// Réconcilie la base locale avec le serveur (ajouts / mises à jour /
/// suppressions) sans télécharger les ressources : les images et PDF sont mis
/// en cache à la demande lors de l'affichage.
class SyncService {
  final ComputeSyncDiffUseCase _computeSyncDiff;
  final ExecuteSyncUseCase _executeSync;

  SyncService(
    SongRepository songRepository,
    RemoteSongRepository remoteSongRepository,
  )   : _computeSyncDiff =
            ComputeSyncDiffUseCase(songRepository, remoteSongRepository),
        _executeSync = ExecuteSyncUseCase(songRepository);

  /// Synchronise la liste locale des chants avec le serveur distant.
  Future<void> syncSongList(String baseUrl) async {
    final diff = await _computeSyncDiff.execute(baseUrl);
    await _executeSync.execute(diff);
  }
}
