import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/core/application/usecases/execute_sync.usecase.dart';
import 'package:songbook/core/domain/model/remote_song.dart';
import 'package:songbook/core/domain/model/resource.dart';
import 'package:songbook/core/domain/model/song.dart';
import 'package:songbook/core/domain/model/sync_diff.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/infrastructure/song/in_memory.song.repository.dart';

import '../../helpers/file_writing.remote_resource.repository.dart';

void main() {
  late Directory tmpDir;
  late InMemorySongRepository songRepository;
  late FileWritingRemoteResourceRepository resourceRepository;
  late ExecuteSyncUseCase useCase;

  final songId1 = UuidValue.parse('00000000-0000-4000-a000-000000000001');
  final resourceId1 = UuidValue.parse('00000000-0000-4000-b000-000000000001');
  final resourceId2 = UuidValue.parse('00000000-0000-4000-b000-000000000002');

  setUp(() {
    tmpDir = Directory.systemTemp.createTempSync('songbook_test_exec_sync_');
    songRepository = InMemorySongRepository();
    resourceRepository = FileWritingRemoteResourceRepository(tmpDir.path);
    useCase = ExecuteSyncUseCase(songRepository, resourceRepository);
  });

  tearDown(() {
    if (tmpDir.existsSync()) {
      tmpDir.deleteSync(recursive: true);
    }
  });

  group('ExecuteSyncUseCase', () {
    test('downloads resources to correct directory for added songs', () async {
      final diff = SyncDiff(
        toAdd: [
          SongToAdd(
            remoteSong: RemoteSong(
              id: songId1,
              code: 'C001',
              name: 'Amazing Grace',
              updatedAt: DateTime(2024, 1, 1),
              resources: [
                RemoteImageResource(
                  id: resourceId1,
                  name: 'Partition',
                  imageUrls: [
                    'https://example.com/page1.jpg',
                    'https://example.com/page2.jpg',
                  ],
                ),
                RemotePdfResource(
                  id: resourceId2,
                  name: 'PDF',
                  pdfUrl: 'https://example.com/doc.pdf',
                ),
              ],
            ),
          ),
        ],
        toUpdate: [],
        toDelete: [],
      );

      await useCase.execute(diff);

      // Vérifier que les fichiers existent dans le bon répertoire
      final songDir = Directory('${tmpDir.path}/${songId1.value}');
      expect(songDir.existsSync(), isTrue);

      expect(
        File('${songDir.path}/page1.jpg').existsSync(),
        isTrue,
      );
      expect(
        File('${songDir.path}/page2.jpg').existsSync(),
        isTrue,
      );
      expect(
        File('${songDir.path}/doc.pdf').existsSync(),
        isTrue,
      );

      // Vérifier que le song est ajouté au repository
      final songs = await songRepository.getAllSongs();
      expect(songs, hasLength(1));
      expect(songs.first.name, 'Amazing Grace');

      // Vérifier que les ressources ont des chemins locaux corrects
      final imageResource = songs.first.resources
          .whereType<ImageResource>()
          .first;
      expect(imageResource.imagePaths, hasLength(2));
      for (final path in imageResource.imagePaths) {
        expect(path, startsWith(tmpDir.path));
        expect(File(path).existsSync(), isTrue);
      }

      final pdfResource = songs.first.resources
          .whereType<PdfResource>()
          .first;
      expect(pdfResource.pdfPath, startsWith(tmpDir.path));
      expect(File(pdfResource.pdfPath).existsSync(), isTrue);
    });

    test('downloads resources to custom sync directory', () async {
      final customDir = Directory.systemTemp.createTempSync(
        'songbook_test_custom_sync_',
      );
      addTearDown(() {
        if (customDir.existsSync()) customDir.deleteSync(recursive: true);
      });

      final customResourceRepo = FileWritingRemoteResourceRepository(
        customDir.path,
      );
      final customUseCase = ExecuteSyncUseCase(
        songRepository,
        customResourceRepo,
      );

      final diff = SyncDiff(
        toAdd: [
          SongToAdd(
            remoteSong: RemoteSong(
              id: songId1,
              code: 'C001',
              name: 'Amazing Grace',
              updatedAt: DateTime(2024, 1, 1),
              resources: [
                RemoteImageResource(
                  id: resourceId1,
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

      await customUseCase.execute(diff);

      // Fichiers dans le custom dir
      expect(
        File('${customDir.path}/${songId1.value}/page1.jpg').existsSync(),
        isTrue,
      );

      // Pas dans le dir par défaut
      expect(
        Directory('${tmpDir.path}/${songId1.value}').existsSync(),
        isFalse,
      );
    });

    test('deletes old resources when updating a song', () async {
      // Pré-populer avec un song existant
      final oldResourcePath = '${tmpDir.path}/${songId1.value}/old_image.jpg';
      await File(oldResourcePath).create(recursive: true);
      await File(oldResourcePath).writeAsString('old content');

      await songRepository.addSong(
        Song(
          id: songId1,
          code: 'C001',
          name: 'Amazing Grace',
          updatedAt: DateTime(2024, 1, 1),
          resources: [
            ImageResource(
              id: resourceId1,
              name: 'Old Partition',
              imagePaths: [oldResourcePath],
            ),
          ],
        ),
      );

      final diff = SyncDiff(
        toAdd: [],
        toUpdate: [
          SongToUpdate(
            localSong: (await songRepository.getAllSongs()).first,
            remoteSong: RemoteSong(
              id: songId1,
              code: 'C001',
              name: 'Amazing Grace Updated',
              updatedAt: DateTime(2024, 6, 1),
              resources: [
                RemoteImageResource(
                  id: resourceId1,
                  name: 'New Partition',
                  imageUrls: ['https://example.com/new_image.jpg'],
                ),
              ],
            ),
          ),
        ],
        toDelete: [],
      );

      await useCase.execute(diff);

      // Ancien fichier supprimé (tout le dossier du song a été recréé)
      expect(File(oldResourcePath).existsSync(), isFalse);

      // Nouveau fichier présent
      expect(
        File('${tmpDir.path}/${songId1.value}/new_image.jpg').existsSync(),
        isTrue,
      );

      // Song mis à jour
      final songs = await songRepository.getAllSongs();
      expect(songs.first.name, 'Amazing Grace Updated');
    });

    test('deletes directory when removing a song', () async {
      // Pré-populer
      final filePath = '${tmpDir.path}/${songId1.value}/image.jpg';
      await File(filePath).create(recursive: true);
      await File(filePath).writeAsString('content');

      final song = Song(
        id: songId1,
        code: 'C001',
        name: 'Amazing Grace',
        updatedAt: DateTime(2024, 1, 1),
        resources: [
          ImageResource(
            id: resourceId1,
            name: 'Partition',
            imagePaths: [filePath],
          ),
        ],
      );
      await songRepository.addSong(song);

      final diff = SyncDiff(
        toAdd: [],
        toUpdate: [],
        toDelete: [SongToDelete(localSong: song)],
      );

      await useCase.execute(diff);

      // Dossier supprimé
      expect(
        Directory('${tmpDir.path}/${songId1.value}').existsSync(),
        isFalse,
      );

      // Song supprimé du repository
      expect(await songRepository.getAllSongs(), isEmpty);
    });
  });
}
