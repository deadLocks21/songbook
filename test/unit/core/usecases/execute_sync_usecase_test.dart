import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/core/domain/model/remote_song.dart';
import 'package:songbook/core/domain/model/resource.dart';
import 'package:songbook/core/domain/model/song.dart';
import 'package:songbook/core/domain/model/sync_diff.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/application/usecases/execute_sync.usecase.dart';
import 'package:songbook/infrastructure/song/in_memory.song.repository.dart';

void main() {
  late InMemorySongRepository songRepository;
  late ExecuteSyncUseCase useCase;

  final songId1 = UuidValue.parse('00000000-0000-4000-a000-000000000001');
  final resourceId1 = UuidValue.parse('00000000-0000-4000-b000-000000000001');
  final resourceId2 = UuidValue.parse('00000000-0000-4000-b000-000000000002');

  setUp(() {
    songRepository = InMemorySongRepository();
    useCase = ExecuteSyncUseCase(songRepository);
  });

  group('ExecuteSyncUseCase', () {
    test('adds new songs with resource URLs (no download)', () async {
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

      final songs = await songRepository.getAllSongs();
      expect(songs, hasLength(1));
      expect(songs.first.name, 'Amazing Grace');

      // Les ressources conservent les URLs distantes telles quelles.
      final imageResource = songs.first.resources
          .whereType<ImageResource>()
          .single;
      expect(imageResource.imageUrls, [
        'https://example.com/page1.jpg',
        'https://example.com/page2.jpg',
      ]);

      final pdfResource = songs.first.resources
          .whereType<PdfResource>()
          .single;
      expect(pdfResource.pdfUrl, 'https://example.com/doc.pdf');
    });

    test('updates a song with the remote version', () async {
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
              imageUrls: ['https://example.com/old.jpg'],
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
                  imageUrls: ['https://example.com/new.jpg'],
                ),
              ],
            ),
          ),
        ],
        toDelete: [],
      );

      await useCase.execute(diff);

      final songs = await songRepository.getAllSongs();
      expect(songs, hasLength(1));
      expect(songs.first.name, 'Amazing Grace Updated');

      final imageResource = songs.first.resources
          .whereType<ImageResource>()
          .single;
      expect(imageResource.imageUrls, ['https://example.com/new.jpg']);
    });

    test('removes deleted songs', () async {
      final song = Song(
        id: songId1,
        code: 'C001',
        name: 'Amazing Grace',
        updatedAt: DateTime(2024, 1, 1),
        resources: [
          ImageResource(
            id: resourceId1,
            name: 'Partition',
            imageUrls: ['https://example.com/page.jpg'],
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

      expect(await songRepository.getAllSongs(), isEmpty);
    });
  });
}
