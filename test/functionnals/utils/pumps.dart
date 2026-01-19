import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/infrastructure/song/providers/song.service_provider.dart';
import 'package:songbook/ui/pages/home/home.page.dart';
import 'package:songbook/ui/pages/song_viewer/song_viewer.page.dart';

import '../../builders/builders.dart';
import 'actions/home/actions.dart';
import 'actions/song_viewer/actions.dart';
import 'app.dart';
import 'page_objects.dart';

// ==================== Test Helpers ====================

/// Démarre l'application avec la HomePage directement.
/// Permet d'injecter des mocks via les overrides Riverpod.
Future<HomePageActions> startInHomePage(WidgetTester tester, {App? app}) async {
  app ??= anApp().build();
  final mockSongs = app.songs;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [songsProvider.overrideWith((ref) async => mockSongs)],
      child: const MaterialApp(home: HomePage()),
    ),
  );

  await tester.pumpAndSettle();

  return PageObjects(tester).homePage;
}

/// Démarre l'application directement sur la SongViewerPage.
Future<SongViewerPageActions> startInSongViewerPage(
  WidgetTester tester, {
  App? app,
}) async {
  app ??= anApp().build();
  final mockSongs = app.songs;
  final mockSong = app.song;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [songsProvider.overrideWith((ref) async => mockSongs)],
      child: MaterialApp(home: SongViewerPage(song: mockSong)),
    ),
  );

  await tester.pumpAndSettle();

  return PageObjects(tester).songViewerPage;
}
