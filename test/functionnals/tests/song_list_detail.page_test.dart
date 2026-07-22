import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/core/application/dtos/resource.dto.dart';

import '../../builders/builders.dart';
import '../utils/index.dart';

void main() {
  group('SongListDetailPage', () {
    testWidgets('should display header with date and count', (tester) async {
      final songList = aSongList()
          .withId('list-1')
          .withScheduledAt(DateTime(2025, 3, 16, 10, 0))
          .withSongEntry(songId: 'song-1', songName: 'Song 1', songCode: 'C001')
          .withSongEntry(songId: 'song-2', songName: 'Song 2', songCode: 'C002')
          .build();

      final app = anApp().withSongLists([songList]).build();

      await (await startInSongListDetailPage(
            tester,
            app: app,
            songListId: 'list-1',
          ))
          .expectHeaderVisible()
          .expectTextVisible('Dim 16 mar 2025, 10:00')
          .expectTextVisible('2 chants')
          .execute();
    });

    testWidgets('should display numbered entries', (tester) async {
      final songList = aSongList()
          .withId('list-1')
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
          .withSongEntry(
            songId: 'song-3',
            songName: 'How Great',
            songCode: 'C003',
          )
          .build();

      final app = anApp().withSongLists([songList]).build();

      await (await startInSongListDetailPage(
            tester,
            app: app,
            songListId: 'list-1',
          ))
          .expectEntryCount(3)
          .expectTextVisible('Amazing Grace')
          .expectTextVisible('C001')
          .expectTextVisible('Holy Spirit')
          .expectTextVisible('How Great')
          .execute();
    });

    testWidgets('should display empty state when list has no entries', (
      tester,
    ) async {
      final songList = aSongList().withId('list-1').build();

      final app = anApp().withSongLists([songList]).build();

      await (await startInSongListDetailPage(
        tester,
        app: app,
        songListId: 'list-1',
      )).expectEmptyStateVisible().execute();
    });

    testWidgets('should show present FAB when list has entries', (
      tester,
    ) async {
      final songList = aSongList()
          .withId('list-1')
          .withSongEntry(songId: 'song-1')
          .build();

      final app = anApp().withSongLists([songList]).build();

      await (await startInSongListDetailPage(
        tester,
        app: app,
        songListId: 'list-1',
      )).expectPresentFabVisible().execute();
    });

    testWidgets('should hide present FAB when list is empty', (tester) async {
      final songList = aSongList().withId('list-1').build();

      final app = anApp().withSongLists([songList]).build();

      await (await startInSongListDetailPage(
        tester,
        app: app,
        songListId: 'list-1',
      )).expectPresentFabNotVisible().execute();
    });

    testWidgets('should navigate to edit page on edit button tap', (
      tester,
    ) async {
      final songList = aSongList()
          .withId('list-1')
          .withSongEntry(
            songId: 'song-1',
            songName: 'Test Song',
            songCode: 'C001',
          )
          .build();

      final app = anApp().withSongLists([songList]).build();

      await (await startInSongListDetailPage(
            tester,
            app: app,
            songListId: 'list-1',
          ))
          .tapEditButton()
          .goToSongListEdit()
          .expectTitle('Modifier la liste')
          .execute();
    });

    testWidgets('should render entries for ChordPro songs without crashing', (
      tester,
    ) async {
      // Régression : la résolution de l'URL ChordPro (pour le chip de tonalité)
      // passait par un `songsById` au type `dynamic`, ce qui faisait échouer
      // `whereType().firstOrNull` au runtime (NoSuchMethodError) dès qu'un chant
      // ChordPro était présent dans la liste.
      final songList = aSongList()
          .withId('list-1')
          .withSongEntry(
            songId: 'song-1',
            songName: 'Amazing Grace',
            songCode: 'C001',
          )
          .build();

      final song = aSong()
          .withId('song-1')
          .withCode('C001')
          .withName('Amazing Grace')
          .withResource(
            const ChordProResourceDto(
              id: 'res-1',
              name: 'ChordPro',
              chordProUrl: 'https://example.com/song-1.cho',
            ),
          )
          .build();

      final app = anApp().withSongsList([song]).withSongLists([
        songList,
      ]).build();

      await (await startInSongListDetailPage(
        tester,
        app: app,
        songListId: 'list-1',
      )).expectTextVisible('Amazing Grace').execute();
    });

    testWidgets('should offer sharing from the detail view', (tester) async {
      // Le partage n'existait que dans le menu contextuel de la vue
      // d'ensemble, atteignable au seul appui long : personne ne le trouvait.
      final app = anApp().withSongLists([
        aSongList().withId('list-1').withSongEntry(songId: 'song-1').build(),
      ]).build();

      await (await startInSongListDetailPage(
        tester,
        app: app,
        songListId: 'list-1',
      )).expectShareButtonVisible().execute();
    });
  });
}
