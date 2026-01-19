import 'package:flutter_test/flutter_test.dart';

import '../../builders/builders.dart';
import '../utils/index.dart';

void main() {
  group('SongViewerPage', () {
    testWidgets('should display song code and name', (tester) async {
      final song = aSong().withCode('042').withName('Amazing Grace').build();
      final app = anApp().withSong(song).build();

      await (await startInSongViewerPage(
        tester,
        app: app,
      )).expectSongCodeIs(song.code).expectSongNameIs(song.name).execute();
    });

    testWidgets('should display no image message when song has no images', (
      tester,
    ) async {
      final app = anApp()
          .withSong(
            aSong()
                .withCode('001')
                .withName('Song Without Images')
                .withoutResources()
                .build(),
          )
          .build();

      await (await startInSongViewerPage(
        tester,
        app: app,
      )).expectNoImageMessageVisible().execute();
    });

    // Note: Le test "should display image viewer when song has images" est
    // difficile à tester car ZoomableImageViewer charge des fichiers de manière
    // asynchrone et les fichiers n'existent pas en environnement de test.
    // Ce test nécessiterait un mock du système de fichiers.

    testWidgets('should navigate back to home page', (tester) async {
      final song = aSong().withCode('001').build();
      final app = anApp().withSong(song).build();

      await (await startInHomePage(tester, app: app))
          .tapSongCard(song.id)
          .goToSongViewer()
          .expectSongCodeIs(song.code)
          .goBack()
          .expectSongGridVisible()
          .execute();
    });
  });
}
