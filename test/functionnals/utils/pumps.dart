import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/infrastructure/recueil/in_memory.remote_recueil.repository.dart';
import 'package:songbook/infrastructure/recueil/providers/recueil.providers.dart';
import 'package:songbook/infrastructure/settings/in_memory.settings_repository.dart';
import 'package:songbook/infrastructure/settings/providers/settings.repository_provider.dart';
import 'package:songbook/infrastructure/song/in_memory.remote_song.repository.dart';
import 'package:songbook/infrastructure/song/providers/song.service_provider.dart';
import 'package:songbook/infrastructure/song/providers/sync.providers.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list.service_provider.dart';
import 'package:songbook/infrastructure/theme/in_memory.theme_repository.dart';
import 'package:songbook/infrastructure/theme/providers/theme.repository_provider.dart';
import 'package:songbook/ui/pages/home/home.page.dart';
import 'package:songbook/ui/pages/song_list_detail/song_list_detail.page.dart';
import 'package:songbook/ui/pages/song_list_edit/song_list_edit.page.dart';
import 'package:songbook/ui/pages/song_list_viewer/providers/song_list_viewer.provider.dart';
import 'package:songbook/ui/pages/song_list_viewer/song_list_viewer.page.dart';
import 'package:songbook/ui/pages/song_lists/song_lists.page.dart';
import 'package:songbook/ui/pages/song_viewer/song_viewer.page.dart';

import '../../builders/builders.dart';
import 'actions/home/actions.dart';
import 'actions/settings/actions.dart';
import 'actions/song_list_detail/actions.dart';
import 'actions/song_list_edit/actions.dart';
import 'actions/song_list_viewer/actions.dart';
import 'actions/song_lists/actions.dart';
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
      overrides: [
        songsProvider.overrideWith((ref) async => mockSongs),
        songListsProvider.overrideWith((ref) async => <SongListDto>[]),
        themeRepositoryProvider.overrideWithValue(InMemoryThemeRepository()),
        settingsRepositoryProvider.overrideWithValue(
          InMemorySettingsRepository(),
        ),
        remoteRecueilRepositoryProvider.overrideWithValue(
          InMemoryRemoteRecueilRepository(),
        ),
        remoteSongRepositoryProvider.overrideWithValue(
          InMemoryRemoteSongRepository(),
        ),
      ],
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
      overrides: [
        songsProvider.overrideWith((ref) async => mockSongs),
        remoteRecueilRepositoryProvider.overrideWithValue(
          InMemoryRemoteRecueilRepository(),
        ),
        remoteSongRepositoryProvider.overrideWithValue(
          InMemoryRemoteSongRepository(),
        ),
      ],
      child: MaterialApp(home: SongViewerPage(song: mockSong)),
    ),
  );

  await tester.pumpAndSettle();

  return PageObjects(tester).songViewerPage;
}

/// Démarre l'application sur la SongListsPage.
Future<SongListsPageActions> startInSongListsPage(
  WidgetTester tester, {
  App? app,
}) async {
  app ??= anApp().build();
  final mockSongs = app.songs;
  final mockSongLists = app.songLists;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        songsProvider.overrideWith((ref) async => mockSongs),
        songListsProvider.overrideWith((ref) async => mockSongLists),
        // Sans quoi tout ce qui touche au backend (partage, abonnement,
        // synchro) irait chercher l'URL dans les vraies préférences et
        // resterait suspendu.
        settingsRepositoryProvider.overrideWithValue(
          InMemorySettingsRepository(),
        ),
      ],
      child: const MaterialApp(home: SongListsPage()),
    ),
  );

  await tester.pumpAndSettle();

  return PageObjects(tester).songListsPage;
}

/// Démarre l'application sur la SongListDetailPage.
Future<SongListDetailPageActions> startInSongListDetailPage(
  WidgetTester tester, {
  required App app,
  required String songListId,
}) async {
  final mockSongs = app.songs;
  final mockSongLists = app.songLists;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        songsProvider.overrideWith((ref) async => mockSongs),
        songListsProvider.overrideWith((ref) async => mockSongLists),
        // Ouvrir une liste suivie déclenche une vérification amont, qui a
        // besoin de l'URL du backend. Sans cette bascule, elle irait la
        // chercher dans les vraies préférences et resterait suspendue.
        settingsRepositoryProvider.overrideWithValue(
          InMemorySettingsRepository(),
        ),
      ],
      child: MaterialApp(home: SongListDetailPage(songListId: songListId)),
    ),
  );

  await tester.pumpAndSettle();

  return PageObjects(tester).songListDetailPage;
}

/// Démarre l'application sur la SongListEditPage.
Future<SongListEditPageActions> startInSongListEditPage(
  WidgetTester tester, {
  required App app,
  required SongListDto songList,
}) async {
  final mockSongs = app.songs;
  final mockSongLists = app.songLists;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        songsProvider.overrideWith((ref) async => mockSongs),
        songListsProvider.overrideWith((ref) async => mockSongLists),
      ],
      child: MaterialApp(home: SongListEditPage(songList: songList)),
    ),
  );

  await tester.pumpAndSettle();

  return PageObjects(tester).songListEditPage;
}

/// Démarre l'application sur la SongListViewerPage.
/// Les chants sont créés sans ressources images pour éviter le timeout
/// du ZoomableImageViewer qui tente de charger des fichiers depuis le disque.
Future<SongListViewerPageActions> startInSongListViewerPage(
  WidgetTester tester, {
  required SongListViewerData viewerData,
  String? initialEntryId,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        songListViewerDataProvider.overrideWith(
          (ref, songListId) async => viewerData,
        ),
      ],
      child: MaterialApp(
        home: SongListViewerPage(
          songListId: viewerData.songList.id,
          initialEntryId: initialEntryId,
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();

  return PageObjects(tester).songListViewerPage;
}

/// Démarre l'application sur la SettingsPage via l'onglet "Paramètres".
Future<SettingsPageActions> startInSettingsPage(
  WidgetTester tester, {
  App? app,
}) async {
  app ??= anApp().build();
  final mockSongs = app.songs;

  // Utiliser une surface plus large pour éviter les overflows sur la page Settings
  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        songsProvider.overrideWith((ref) async => mockSongs),
        songListsProvider.overrideWith((ref) async => <SongListDto>[]),
        themeRepositoryProvider.overrideWithValue(InMemoryThemeRepository()),
        settingsRepositoryProvider.overrideWithValue(
          InMemorySettingsRepository(),
        ),
        remoteRecueilRepositoryProvider.overrideWithValue(
          InMemoryRemoteRecueilRepository(),
        ),
        remoteSongRepositoryProvider.overrideWithValue(
          InMemoryRemoteSongRepository(),
        ),
      ],
      child: const MaterialApp(home: HomePage()),
    ),
  );

  await tester.pumpAndSettle();

  // Naviguer vers l'onglet "Paramètres" (index 2)
  await tester.tap(find.text('Paramètres'));
  await tester.pumpAndSettle();

  return PageObjects(tester).settingsPage;
}
