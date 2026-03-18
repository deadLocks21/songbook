import 'package:flutter_test/flutter_test.dart';

import '../../builders/builders.dart';
import '../utils/index.dart';

void main() {
  group('SongListEditPage - Creation', () {
    testWidgets('should show "Nouvelle liste" title for new list', (
      tester,
    ) async {
      final songList = aSongList().withId('new-list').build();
      final app = anApp().build();

      await (await startInSongListEditPage(
        tester,
        app: app,
        songList: songList,
      )).expectTitle('Nouvelle liste').execute();
    });

    testWidgets('should show empty state for new list', (tester) async {
      final songList = aSongList().withId('new-list').build();
      final app = anApp().build();

      await (await startInSongListEditPage(
        tester,
        app: app,
        songList: songList,
      )).expectEmptyStateVisible().expectEntriesCount(0).execute();
    });

    testWidgets('should display scheduled date', (tester) async {
      final songList = aSongList()
          .withId('new-list')
          .withScheduledAt(DateTime(2025, 3, 16, 10, 0))
          .build();
      final app = anApp().build();

      await (await startInSongListEditPage(
        tester,
        app: app,
        songList: songList,
      )).expectTextVisible('Dim 16 mar 2025, 10:00').execute();
    });
  });

  group('SongListEditPage - Edition', () {
    testWidgets('should show "Modifier la liste" title for existing list', (
      tester,
    ) async {
      final songList = aSongList()
          .withId('existing-list')
          .withSongEntry(songId: 'song-1', songName: 'Song 1', songCode: 'C001')
          .build();
      final app = anApp().build();

      await (await startInSongListEditPage(
        tester,
        app: app,
        songList: songList,
      )).expectTitle('Modifier la liste').execute();
    });

    testWidgets('should load existing entries', (tester) async {
      final songList = aSongList()
          .withId('existing-list')
          .withSongEntry(
            songId: 'song-1',
            songName: 'Amazing Grace',
            songCode: 'C001',
          )
          .withSongEntry(
            songId: 'song-2',
            songName: 'Holy Spirit',
            songCode: 'C002',
          )
          .build();
      final app = anApp().build();

      await (await startInSongListEditPage(
            tester,
            app: app,
            songList: songList,
          ))
          .expectReorderableListVisible()
          .expectEntriesCount(2)
          .expectTextVisible('Amazing Grace')
          .expectTextVisible('Holy Spirit')
          .execute();
    });

    testWidgets('should remove entry when remove button is tapped', (
      tester,
    ) async {
      final songList = aSongList()
          .withId('existing-list')
          .withSongEntry(songId: 'song-1', songName: 'Song 1', songCode: 'C001')
          .withSongEntry(songId: 'song-2', songName: 'Song 2', songCode: 'C002')
          .build();
      final app = anApp().build();

      await (await startInSongListEditPage(
            tester,
            app: app,
            songList: songList,
          ))
          .expectEntriesCount(2)
          .removeEntryAt(0)
          .expectEntriesCount(1)
          .expectTextNotVisible('Song 1')
          .execute();
    });

    testWidgets('should show entries count label', (tester) async {
      final songList = aSongList()
          .withId('existing-list')
          .withSongEntry(songId: 'song-1', songName: 'Song 1', songCode: 'C001')
          .withSongEntry(songId: 'song-2', songName: 'Song 2', songCode: 'C002')
          .withSongEntry(songId: 'song-3', songName: 'Song 3', songCode: 'C003')
          .build();
      final app = anApp().build();

      await (await startInSongListEditPage(
        tester,
        app: app,
        songList: songList,
      )).expectEntriesCount(3).execute();
    });
  });
}
