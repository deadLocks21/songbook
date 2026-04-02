## Context

La couche application actuelle suit un pattern use-case-per-class issu de Clean Architecture / DDD. Chaque opération (même triviale) est une classe avec un constructeur pour l'injection et une méthode `execute()`. Ces use cases sont agrégés dans des "service bags" (`SongApplicationService`, `SongListApplicationService`) qui n'ajoutent aucune logique. Les providers Riverpod câblent chaque use case individuellement, créant une chaîne Provider → Service → UseCase → Repository à 4 niveaux.

L'app est un songbook (catalogue de chansons, listes de concert, synchronisation avec un serveur distant). Le domaine métier est simple — il ne justifie pas la granularité d'une architecture use-case-per-class.

## Goals / Non-Goals

**Goals:**
- Pattern unique et cohérent : Provider → Service.method() → Repository, sans exception
- Réduire le nombre de fichiers (~-13 fichiers) et de niveaux d'indirection
- Organiser les services par **intention utilisateur** (pas par entité de domaine)
- Préserver la possibilité de déléguer à des use cases internes pour la logique complexe

**Non-Goals:**
- Refactoring des DTOs (traité séparément, plus tard)
- Passage en feature-first (on garde l'organisation par couche)
- Modification du comportement fonctionnel de l'app
- Changement des repositories ou du domaine

## Decisions

### 1. Services organisés par intention utilisateur, pas par entité

**Choix** : 4 services découpés par ce que l'utilisateur cherche à faire (SettingsService, SongCatalogService, SetlistService, SyncService) plutôt que par entité (SongService, SongListService, etc.).

**Alternative rejetée** : Services par entité — crée de l'ambiguïté pour les opérations cross-entité ("ajouter un song à une liste" → SongService ou SongListService ?).

**Rationale** : Le découpage par intention rend le placement de chaque nouvelle méthode évident. Test : pour chaque fonctionnalité, on doit savoir immédiatement dans quel service elle va.

### 2. Use cases complexes conservés comme détails d'implémentation internes

**Choix** : Les use cases dont la logique est substantielle (`ComputeSyncDiffUseCase`, `ExecuteSyncUseCase`, `SetSyncDirectoryUseCase`) restent en tant que classes, mais deviennent des dépendances internes de leur service. Ils ne sont plus exposés publiquement.

**Alternative rejetée** : Tout inliner dans les méthodes du service — les méthodes de SyncService deviendraient trop longues et difficiles à lire.

**Rationale** : Le service est la façade publique, le use case est un détail d'organisation du code. Vu de l'extérieur, c'est toujours `syncService.computeDiff()`.

### 3. SyncService injecte directement le SettingsRepository

**Choix** : `SyncService` dépend directement de `SettingsRepository` pour lire le mot de passe, plutôt que de dépendre de `SettingsService`.

**Alternative rejetée** : Couplage inter-services (SyncService → SettingsService) — ajoute une dépendance entre services qui complexifie le graphe d'injection.

**Rationale** : Les services ne dépendent que de repositories. Ça garde le graphe de dépendances plat.

### 4. SettingsService absorbe le thème

**Choix** : Le thème (get/setThemeMode) est traité comme une préférence utilisateur et rejoint `SettingsService`, qui dépend de `SettingsRepository` ET `ThemeRepository`.

**Rationale** : Du point de vue de l'intention, "changer le thème" est "configurer l'app". La séparation technique (deux repos) ne justifie pas un service séparé.

### 5. Migration par étapes indépendantes

**Choix** : Migrer un service à la fois, dans l'ordre croissant de complexité.

**Rationale** : Chaque étape est autonome et déployable. On pose le pattern sur le cas le plus simple (Settings), puis on l'applique aux cas plus complexes avec confiance.

## Risks / Trade-offs

- **Services avec beaucoup de méthodes** : `SettingsService` aura 8 méthodes (get/set pour URL, password, theme, syncDir). C'est acceptable pour des méthodes simples, mais à surveiller si la logique grossit. → Mitigation : extraire un use case interne si une méthode devient complexe.

- **Deux repos dans SettingsService** : `SettingsRepository` + `ThemeRepository` dans un même service est un léger couplage. → Mitigation : acceptable car les deux sont des préférences stockées localement. Si le thème devient plus complexe (thèmes custom, etc.), on pourrait le séparer.

- **Les fichiers use case internes n'ont plus de convention de nommage publique** : il faut une convention pour les distinguer. → Mitigation : les garder dans le même dossier que le service qui les utilise, ou dans un sous-dossier `internal/`.
