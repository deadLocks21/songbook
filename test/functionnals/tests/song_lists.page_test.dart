import 'package:flutter_test/flutter_test.dart';

import '../../builders/builders.dart';
import '../utils/index.dart';

void main() {
  group('SongListsPage', () {
    testWidgets('should display song lists when loaded', (tester) async {
      final app = anApp().withSongLists([
        aSongList().withId('list-1').build(),
        aSongList().withId('list-2').build(),
      ]).build();

      await (await startInSongListsPage(
        tester,
        app: app,
      )).expectListVisible().expectSongListCount(2).execute();
    });

    testWidgets('should display empty message when no lists', (tester) async {
      final app = anApp().withSongLists([]).build();

      await (await startInSongListsPage(
        tester,
        app: app,
      )).expectEmptyMessageVisible().execute();
    });

    testWidgets('should display date and song count on card', (tester) async {
      final app = anApp().withSongLists([
        aSongList()
            .withId('list-1')
            .withScheduledAt(DateTime(2025, 3, 16, 10, 0))
            .withSongEntry(songId: 'song-1', songName: 'Song 1')
            .withSongEntry(songId: 'song-2', songName: 'Song 2')
            .build(),
      ]).build();

      await (await startInSongListsPage(tester, app: app))
          .expectSongListCount(1)
          .expectTextVisible('Dim 16 mar 2025, 10:00')
          .expectTextVisible('2 chants')
          .execute();
    });

    testWidgets('should show singular "chant" for single entry', (
      tester,
    ) async {
      final app = anApp().withSongLists([
        aSongList().withId('list-1').withSongEntry(songId: 'song-1').build(),
      ]).build();

      await (await startInSongListsPage(
        tester,
        app: app,
      )).expectTextVisible('1 chant').execute();
    });

    testWidgets('should navigate to detail on card tap', (tester) async {
      final songList = aSongList()
          .withId('list-1')
          .withScheduledAt(DateTime(2025, 3, 16, 10, 0))
          .withSongEntry(
            songId: 'song-1',
            songName: 'Amazing Grace',
            songCode: 'C001',
          )
          .build();

      final app = anApp().withSongLists([songList]).build();

      await (await startInSongListsPage(tester, app: app))
          .tapSongListCard('list-1')
          .goToSongListDetail()
          .expectHeaderVisible()
          .expectTextVisible('Dim 16 mar 2025, 10:00')
          .execute();
    });

    group('partage et abonnement', () {
      testWidgets('should mark lists copied from someone else', (tester) async {
        // La copie appartient bien à l'utilisateur, mais savoir qu'elle a une
        // source change ce qu'il en attend : elle peut évoluer en amont.
        final app = anApp().withSongLists([
          aSongList().withId('list-1').following().build(),
          aSongList().withId('list-2').build(),
        ]).build();

        await (await startInSongListsPage(tester, app: app))
            .expectSongListCount(2)
            .expectFollowedBadgeCount(1)
            .execute();
      });

      testWidgets('should offer sharing from the context menu', (tester) async {
        final app = anApp().withSongLists([
          aSongList().withId('list-1').build(),
        ]).build();

        await (await startInSongListsPage(tester, app: app))
            .longPressSongListCard('list-1')
            .expectShareActionVisible()
            .execute();
      });

      testWidgets('should open the follow dialog from the FAB', (tester) async {
        final app = anApp().withSongLists([]).build();

        await (await startInSongListsPage(tester, app: app))
            .tapFollowFab()
            .expectFollowDialogVisible()
            .expectTextVisible('Suivre une liste')
            .execute();
      });

      testWidgets('should reject a code that matches nothing', (tester) async {
        // Le mode démo n'émet aucun partage : n'importe quel code y est
        // inconnu, ce qui est exactement le cas à afficher proprement.
        final app = anApp().withSongLists([]).build();

        await (await startInSongListsPage(tester, app: app))
            .tapFollowFab()
            .enterFollowCode('K7Q2M9XZ')
            .submitFollowCode()
            .expectTextVisible('Ce code ne correspond à aucune liste partagée.')
            .execute();
      });
    });
  });
}
