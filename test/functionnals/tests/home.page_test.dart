import 'package:flutter_test/flutter_test.dart';

import '../../builders/builders.dart';
import '../utils/index.dart';

void main() {
  group('HomePage', () {
    testWidgets('should display song grid when songs are loaded', (
      tester,
    ) async {
      final app = anApp().withSongsList([
        aSong().build(),
        aSong().build(),
        aSong().build(),
      ]).build();

      await (await startInHomePage(
        tester,
        app: app,
      )).expectSongGridVisible().expectSongCount(3).execute();
    });

    testWidgets('should display empty message when no songs', (tester) async {
      final app = anApp().withSongsList([]).build();
      await (await startInHomePage(
        tester,
        app: app,
      )).expectEmptyMessageVisible().execute();
    });

    testWidgets('should filter songs by search query', (tester) async {
      final app = anApp().withSongsList([
        aSong().withName('Amazing Grace').build(),
        aSong().withName('Holy Spirit').build(),
        aSong().withName('Amazing Love').build(),
      ]).build();

      await (await startInHomePage(tester, app: app))
          .expectSongCount(3)
          .enterSearchQuery('Amazing')
          .expectSongCount(2)
          .execute();
    });

    testWidgets('should filter songs by code', (tester) async {
      final app = anApp().withSongsList([
        aSong().withCode('ABC').build(),
        aSong().withCode('XYZ').build(),
      ]).build();

      await (await startInHomePage(tester, app: app))
          .expectSongCount(2)
          .enterSearchQuery('ABC')
          .expectSongCount(1)
          .execute();
    });

    testWidgets('should show empty message when search has no results', (
      tester,
    ) async {
      final app = anApp().withSongsList([aSong().build()]).build();

      await (await startInHomePage(tester, app: app))
          .expectSongCount(1)
          .enterSearchQuery('NOTFOUND')
          .expectEmptyMessageVisible()
          .execute();
    });

    testWidgets('should navigate to song viewer on card tap', (tester) async {
      final app = anApp()
          .withSong(
            aSong()
                .withId('song-1')
                .withCode('001')
                .withName('Test Song')
                .build(),
          )
          .build();

      await (await startInHomePage(tester, app: app))
          .tapSongCard('song-1')
          .goToSongViewer()
          .expectSongCodeIs('001')
          .expectSongNameIs('Test Song')
          .execute();
    });
  });
}
