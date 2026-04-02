## Why

La couche application contient 16 use cases (classes individuelles) agrégés dans 2 "service bags" sans logique propre (`SongApplicationService`, `SongListApplicationService`). Cela crée un pattern à deux niveaux (service + use case) là où un seul suffirait, avec beaucoup de boilerplate de câblage dans les providers Riverpod. L'objectif est de fusionner ces deux concepts en un seul : des **services applicatifs avec des méthodes**, qui peuvent déléguer à des use cases internes quand la logique est complexe.

## What Changes

- **Suppression des 16 fichiers use case** en tant que classes publiques autonomes. Les use cases complexes (ComputeSyncDiff, ExecuteSync, SetSyncDirectory) sont conservés comme détails d'implémentation internes de leur service.
- **Suppression des 2 service bags** (`SongApplicationService`, `SongListApplicationService`) qui ne font qu'agréger des use cases sans logique.
- **Création de 4 services applicatifs** organisés par intention utilisateur :
  - `SettingsService` — préférences de l'app (URL backend, mot de passe, thème, dossier de sync)
  - `SongCatalogService` — consultation du catalogue de chansons
  - `SetlistService` — gestion des listes de concert
  - `SyncService` — synchronisation avec le serveur distant
- **Simplification des providers Riverpod** : un provider par service au lieu de providers par use case.
- Le pattern devient unique et cohérent : **Provider → Service.method() → Repository**, sans exception.

## Capabilities

### New Capabilities

- `application-services`: Définition des 4 services applicatifs (SettingsService, SongCatalogService, SetlistService, SyncService), leurs méthodes, leurs dépendances, et la règle de délégation aux use cases internes pour la logique complexe.

### Modified Capabilities

_(aucune modification de comportement fonctionnel — refactoring interne uniquement)_

## Impact

- **Couche application** (`lib/core/application/`) : restructuration complète — suppression des use cases publics et service bags, création des nouveaux services
- **Providers Riverpod** (`lib/infrastructure/**/providers/`) : simplification du câblage — les providers exposent des services au lieu de use cases individuels
- **Notifiers UI** (`lib/ui/**/providers/`) : changement des dépendances (service au lieu de use cases)
- **Aucun impact sur** : les repositories, les modèles de domaine, les widgets UI, les DTOs
- **Aucun changement fonctionnel** : le comportement de l'app reste identique
