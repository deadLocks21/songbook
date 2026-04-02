## 1. SettingsService (Theme + Settings)

- [x] 1.1 Créer `lib/core/application/services/settings.service.dart` avec les méthodes : `getBackendUrl`, `setBackendUrl` (+ clear password), `getPassword`, `setPassword`, `getSyncDirectory`, `setSyncDirectory` (délègue au use case interne), `getThemeMode`, `setThemeMode`. Dépendances : `SettingsRepository`, `ThemeRepository`.
- [x] 1.2 Migrer `SetSyncDirectoryUseCase` comme dépendance interne de `SettingsService` (instancié dans le constructeur du service, non exposé publiquement)
- [x] 1.3 Créer le provider `@riverpod SettingsService settingsService(Ref ref)` dans un nouveau fichier `lib/infrastructure/settings/providers/settings.service_provider.dart`
- [x] 1.4 Migrer `BackendUrlNotifier` et `SyncDirectoryNotifier` pour utiliser `SettingsService` au lieu des use cases
- [x] 1.5 Migrer `ThemeModeNotifier` pour utiliser `SettingsService` au lieu des use cases
- [x] 1.6 Supprimer les fichiers use case : `get_backend_url.usecase.dart`, `set_backend_url.usecase.dart`, `get_password.usecase.dart`, `set_password.usecase.dart`, `get_sync_directory.usecase.dart`, `get_theme_mode.usecase.dart`, `set_theme_mode.usecase.dart`
- [x] 1.7 Supprimer les anciens providers de use cases dans `settings.usecases_provider.dart` et `theme.usecases_provider.dart` (gardé setPasswordUseCaseProvider temporairement pour sync_state)
- [x] 1.8 Vérifier que l'app compile et que les settings + thème fonctionnent

## 2. SongCatalogService

- [x] 2.1 Créer `lib/core/application/services/song_catalog.service.dart` avec les méthodes : `getAllSongs` (sort + map DTO), `clearDatabase`. Dépendances : `SongRepository`, `RemoteResourceRepository`.
- [x] 2.2 Créer le provider `@riverpod SongCatalogService songCatalogService(Ref ref)` et migrer le provider `songs` pour utiliser le service
- [x] 2.3 Migrer les consumers qui utilisaient `SongApplicationService` ou `GetAllSongsUseCase`
- [x] 2.4 Supprimer `get_all_songs.usecase.dart`, `clear_database.usecase.dart`, `song_application.service.dart`
- [x] 2.5 Supprimer les anciens providers : `clear_database.provider.dart` (song.service_provider.dart réécrit en place)
- [x] 2.6 Vérifier que l'app compile et que le catalogue de chansons fonctionne

## 3. SetlistService

- [x] 3.1 Créer `lib/core/application/services/setlist.service.dart` avec les méthodes : `getAllSetlists`, `getDetail`, `save`, `delete`. Dépendances : `SongListRepository`, `SongRepository`.
- [x] 3.2 Créer le provider `@riverpod SetlistService setlistService(Ref ref)` et migrer le provider `songLists`
- [x] 3.3 Migrer les consumers qui utilisaient `SongListApplicationService` (pages song_list_edit, song_list_viewer, song_lists)
- [x] 3.4 Supprimer `get_all_song_lists.usecase.dart`, `get_song_list_detail.usecase.dart`, `save_song_list.usecase.dart`, `delete_song_list.usecase.dart`, `song_list_application.service.dart`
- [x] 3.5 Supprimer les anciens providers dans `song_list.service_provider.dart` (réécrit en place)
- [x] 3.6 Vérifier que l'app compile et que les setlists fonctionnent

## 4. SyncService

- [x] 4.1 Créer `lib/core/application/services/sync.service.dart` avec les méthodes : `computeDiff`, `executeSync`. Dépendances : `SongRepository`, `RemoteSongRepository`, `RemoteResourceRepository`, `SettingsRepository`. Instancie `ComputeSyncDiffUseCase` et `ExecuteSyncUseCase` en interne.
- [x] 4.2 Déplacer `ComputeSyncDiffUseCase` et `ExecuteSyncUseCase` comme fichiers internes (ou les garder en place mais retirer leur exposition publique via providers)
- [x] 4.3 Créer le provider `@riverpod SyncService syncService(Ref ref)` dans `sync.providers.dart`
- [x] 4.4 Migrer `SyncStateNotifier` pour utiliser `SyncService` au lieu des use cases individuels
- [x] 4.5 Supprimer les anciens providers de use cases (`computeSyncDiffUseCase`, `executeSyncUseCase`, `setPasswordUseCase`) dans `sync.providers.dart` et `settings.usecases_provider.dart`
- [x] 4.6 Vérifier que l'app compile et que la synchronisation fonctionne

## 5. Nettoyage final

- [x] 5.1 Vérifier le dossier `lib/core/application/usecases/` — 3 use cases complexes restent (internes aux services) (les use cases complexes ayant été déplacés ou gardés comme internes)
- [x] 5.2 Vérifier qu'il ne reste aucune référence aux anciens use cases ou service bags dans le code
- [x] 5.3 Lancer un build complet (flutter analyze) pour validation finale
