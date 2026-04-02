## ADDED Requirements

### Requirement: SettingsService regroupe toutes les préférences utilisateur

Le système SHALL exposer un `SettingsService` avec des méthodes pour gérer toutes les préférences : URL backend, mot de passe, thème et dossier de synchronisation. Le service SHALL dépendre de `SettingsRepository` et `ThemeRepository`. Les méthodes triviales (get/set) SHALL appeler directement le repository. `setBackendUrl` SHALL effacer le mot de passe stocké (logique existante). `setSyncDirectory` SHALL déléguer à un use case interne (logique complexe de copie de fichiers).

#### Scenario: Lecture et écriture du thème via SettingsService
- **WHEN** un consumer appelle `settingsService.getThemeMode()` ou `settingsService.setThemeMode(mode)`
- **THEN** le service délègue à `ThemeRepository` et retourne/persiste le `ThemeMode`

#### Scenario: Changement d'URL backend efface le mot de passe
- **WHEN** un consumer appelle `settingsService.setBackendUrl(url)`
- **THEN** le service persiste la nouvelle URL ET efface le mot de passe stocké

#### Scenario: Changement de dossier de sync délègue au use case interne
- **WHEN** un consumer appelle `settingsService.setSyncDirectory(path, onProgress)`
- **THEN** le service délègue à `SetSyncDirectoryUseCase` qui gère la copie de fichiers et la persistance du chemin

### Requirement: SongCatalogService expose la consultation du catalogue

Le système SHALL exposer un `SongCatalogService` avec des méthodes pour lire et nettoyer le catalogue de chansons. Le service SHALL dépendre de `SongRepository` et `RemoteResourceRepository`.

#### Scenario: Récupération de toutes les chansons triées
- **WHEN** un consumer appelle `songCatalogService.getAllSongs()`
- **THEN** le service retourne toutes les chansons triées par code, mappées en DTOs

#### Scenario: Nettoyage de la base de données
- **WHEN** un consumer appelle `songCatalogService.clearDatabase()`
- **THEN** le service supprime les fichiers de ressources (sauf sur web) puis supprime toutes les chansons

### Requirement: SetlistService expose la gestion des listes de concert

Le système SHALL exposer un `SetlistService` avec les méthodes CRUD pour les listes de concert. Le service SHALL dépendre de `SongListRepository` et `SongRepository`.

#### Scenario: Récupération de toutes les setlists
- **WHEN** un consumer appelle `setlistService.getAllSetlists()`
- **THEN** le service retourne toutes les listes avec les infos de chansons résolues, triées par date décroissante

#### Scenario: Détail d'une setlist
- **WHEN** un consumer appelle `setlistService.getDetail(id)`
- **THEN** le service retourne la setlist avec les chansons chargées par batch

#### Scenario: Sauvegarde d'une setlist (create ou update)
- **WHEN** un consumer appelle `setlistService.save(dto)`
- **THEN** le service vérifie l'existence et appelle add ou update sur le repository

#### Scenario: Suppression d'une setlist
- **WHEN** un consumer appelle `setlistService.delete(id)`
- **THEN** le service supprime la setlist via le repository

### Requirement: SyncService expose la synchronisation avec le serveur

Le système SHALL exposer un `SyncService` avec des méthodes pour calculer le diff et exécuter la synchronisation. Le service SHALL dépendre de `SongRepository`, `RemoteSongRepository`, `RemoteResourceRepository` et `SettingsRepository`. Les méthodes complexes SHALL déléguer à des use cases internes (`ComputeSyncDiffUseCase`, `ExecuteSyncUseCase`).

#### Scenario: Calcul du diff de synchronisation
- **WHEN** un consumer appelle `syncService.computeDiff(url, onProgress)`
- **THEN** le service délègue à `ComputeSyncDiffUseCase` qui compare les chansons locales et distantes et retourne un `SyncDiff`

#### Scenario: Exécution de la synchronisation
- **WHEN** un consumer appelle `syncService.executeSync(diff, onProgress)`
- **THEN** le service délègue à `ExecuteSyncUseCase` qui applique les suppressions, mises à jour et ajouts avec téléchargement de ressources

### Requirement: Pattern unique Provider → Service → Repository

Tous les accès à la logique applicative depuis les providers Riverpod SHALL passer par un service. Aucun provider ne SHALL exposer un use case directement. Les use cases complexes SHALL être des détails d'implémentation internes des services, instanciés par le service lui-même.

#### Scenario: Provider de service Riverpod
- **WHEN** un provider applicatif est créé
- **THEN** il instancie un service en lui passant les repositories et retourne le service

#### Scenario: Notifier utilise un service
- **WHEN** un Notifier Riverpod a besoin de logique applicative
- **THEN** il appelle une méthode du service correspondant, jamais un use case directement
