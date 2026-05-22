import 'package:songbook/core/application/usecases/compute_sync_diff.usecase.dart';
import 'package:songbook/core/application/usecases/execute_sync.usecase.dart';
import 'package:songbook/core/domain/model/sync_diff.dart';
import 'package:songbook/core/domain/services/remote_resource.repository.dart';
import 'package:songbook/core/domain/services/remote_song.repository.dart';
import 'package:songbook/core/domain/services/settings.repository.dart';
import 'package:songbook/core/domain/services/song.repository.dart';

class SyncService {
  final SettingsRepository _settingsRepository;
  final ComputeSyncDiffUseCase _computeSyncDiff;
  final ExecuteSyncUseCase _executeSync;

  SyncService(
    SongRepository songRepository,
    RemoteSongRepository remoteSongRepository,
    RemoteResourceRepository resourceRepository,
    this._settingsRepository,
  )   : _computeSyncDiff =
            ComputeSyncDiffUseCase(songRepository, remoteSongRepository),
        _executeSync =
            ExecuteSyncUseCase(songRepository, resourceRepository);

  Future<SyncDiff> computeDiff(String baseUrl,
          {void Function(double)? onProgress}) =>
      _computeSyncDiff.execute(baseUrl, onProgress: onProgress);

  Future<void> executeSync(SyncDiff diff,
          {void Function(double)? onProgress}) =>
      _executeSync.execute(diff, onProgress: onProgress);

  Future<void> setPassword(String password) =>
      _settingsRepository.setPassword(password);
}
