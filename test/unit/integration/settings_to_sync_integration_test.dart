import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/core/application/usecases/execute_sync.usecase.dart';
import 'package:songbook/core/application/usecases/set_sync_directory.usecase.dart';
import 'package:songbook/core/domain/model/remote_song.dart';
import 'package:songbook/core/domain/model/sync_diff.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/infrastructure/settings/in_memory.settings_repository.dart';
import 'package:songbook/infrastructure/song/in_memory.song.repository.dart';

import '../helpers/file_writing.remote_resource.repository.dart';

void main() {
  late Directory tmpDefaultDir;
  late InMemorySettingsRepository settingsRepository;
  late InMemorySongRepository songRepository;

  final songId = UuidValue.parse('00000000-0000-4000-a000-000000000001');
  final resourceId = UuidValue.parse('00000000-0000-4000-b000-000000000001');

  setUp(() {
    tmpDefaultDir = Directory.systemTemp.createTempSync(
      'songbook_test_integ_default_',
    );
    settingsRepository = InMemorySettingsRepository();
    songRepository = InMemorySongRepository();
  });

  tearDown(() {
    if (tmpDefaultDir.existsSync()) {
      tmpDefaultDir.deleteSync(recursive: true);
    }
  });

  SyncDiff createSyncDiffWithOneSong() {
    return SyncDiff(
      toAdd: [
        SongToAdd(
          remoteSong: RemoteSong(
            id: songId,
            code: 'C001',
            name: 'Amazing Grace',
            updatedAt: DateTime(2024, 1, 1),
            resources: [
              RemoteImageResource(
                id: resourceId,
                name: 'Partition',
                imageUrls: ['https://example.com/page1.jpg'],
              ),
            ],
          ),
        ),
      ],
      toUpdate: [],
      toDelete: [],
    );
  }

  group('Settings → Sync → File I/O integration', () {
    test('sync writes files to default directory when no custom path', () async {
      // 1. Pas de custom dir → utilise le default
      final resourceRepo = FileWritingRemoteResourceRepository(
        tmpDefaultDir.path,
      );
      final syncUseCase = ExecuteSyncUseCase(songRepository, resourceRepo);

      await syncUseCase.execute(createSyncDiffWithOneSong());

      // Fichiers dans le default dir
      expect(
        File('${tmpDefaultDir.path}/${songId.value}/page1.jpg').existsSync(),
        isTrue,
      );
    });

    test('after changing sync dir, migrated files are in new location',
        () async {
      // 1. Sync vers le default dir
      final defaultResourceRepo = FileWritingRemoteResourceRepository(
        tmpDefaultDir.path,
      );
      final syncUseCase = ExecuteSyncUseCase(
        songRepository,
        defaultResourceRepo,
      );
      await syncUseCase.execute(createSyncDiffWithOneSong());

      expect(
        File('${tmpDefaultDir.path}/${songId.value}/page1.jpg').existsSync(),
        isTrue,
      );

      // 2. Changer le sync directory
      final customDir = Directory.systemTemp.createTempSync(
        'songbook_test_integ_custom_',
      );
      addTearDown(() {
        if (customDir.existsSync()) customDir.deleteSync(recursive: true);
      });

      final setSyncDirUseCase = SetSyncDirectoryUseCase(
        settingsRepository,
        defaultPathResolver: () async => tmpDefaultDir.path,
      );
      await setSyncDirUseCase.execute(customDir.path);

      // 3. Vérifier la migration
      // Fichiers migrés dans le custom dir
      expect(
        File('${customDir.path}/${songId.value}/page1.jpg').existsSync(),
        isTrue,
      );
      // Ancien dir supprimé
      expect(tmpDefaultDir.existsSync(), isFalse);

      // Settings mis à jour
      expect(await settingsRepository.getSyncDirectory(), customDir.path);
    });

    test('new sync after dir change writes to new location', () async {
      // 1. Configurer un custom dir dans les settings
      final customDir = Directory.systemTemp.createTempSync(
        'songbook_test_integ_newsync_',
      );
      addTearDown(() {
        if (customDir.existsSync()) customDir.deleteSync(recursive: true);
      });

      await settingsRepository.setSyncDirectory(customDir.path);

      // 2. Résoudre le chemin depuis les settings (comme le provider le fait)
      final syncDir = await settingsRepository.getSyncDirectory();
      final resourceRepo = FileWritingRemoteResourceRepository(syncDir!);
      final syncUseCase = ExecuteSyncUseCase(songRepository, resourceRepo);

      await syncUseCase.execute(createSyncDiffWithOneSong());

      // Fichiers dans le custom dir
      expect(
        File('${customDir.path}/${songId.value}/page1.jpg').existsSync(),
        isTrue,
      );

      // Pas dans le default dir
      expect(
        Directory('${tmpDefaultDir.path}/${songId.value}').existsSync(),
        isFalse,
      );
    });
  });
}
