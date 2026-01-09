# Architecture du Projet

## Vue d'ensemble

Ce projet suit une architecture hexagonale (Clean Architecture), qui sépare clairement les responsabilités et garantit une maintenance et une évolution facilitées.  
L'architecture est organisée en couches distinctes, avec des **dépendances unidirectionnelles** et un respect strict des contrats.

---

## Structure des Dossiers

### 📁 `lib/`
```
lib/
├── main.dart                    # Point d'entrée de l'application
├── shared/                      # Utilitaires génériques + configuration d'environnement
├── core/                        # Cœur métier (Domain + Application)
│   ├── domain/                  # Couche Domain : règles métier
│   └── application/             # Couche Application : cas d'usage
├── infrastructure/              # Couche Infrastructure : implémentations concrètes
│   └── providers/               # Providers Riverpod qui assemblent les implémentations
└── ui/                          # Couche UI : interface Flutter

```

## Fonction de chaque couche

### 🎯 **Domain** (`lib/core/domain/`)
**Responsabilité** : Contient les règles métier, les entités, les interfaces, et les exceptions métier.

**Contenu** :
- `model/` : Entités du domaine (ex : `Source`)
- `services/` : Interfaces des services métier (ex : `SourceRepository`)
- `exceptions/` : Exceptions métier

**Caractéristiques** :
- **Aucune dépendance vers les autres couches**
- Logique métier pure
- Définit les **contrats** que les autres couches doivent implémenter

**Règles strictes** :
- ❌ Pas de Riverpod
- ❌ Pas d'HTTP
- ❌ Pas de Flutter
- ❌ Pas de mapping vers l'UI
- ❌ Pas de try/catch système
- ✅ Pure logique métier uniquement

---

### ⚙️ **Application** (`lib/core/application/`)

**Responsabilité** : Orchestrer les **cas d'usage métier** de l'application.

> **Domain = règle métier pure**  
> **Application = orchestration des règles métier**

#### 🎯 Rôle exact de la couche Application

##### 1. Coordonner plusieurs appels à Domain

Un cas d'usage peut :
- Appeler plusieurs repositories
- Vérifier des conditions métier
- Orchestrer un workflow complexe

##### 2. Faire du "mapping" entre modèles

- Transformer une entité `Source` (Domain) en `SourceDto` (UI)
- Combiner plusieurs entités en une seule structure de sortie
- Adapter des formats pour l'UI, mais **sans dépendre de Flutter**

##### 3. Gérer les erreurs métier et workflow d'erreur

- Catch des exceptions Domain
- Retourner un sealed class type `Either`, `Result`, `Failure`, `Success`
- Transformer exceptions → messages de domaine → messages d'UI

##### 4. Encapsuler la logique d'application

- Validation de formats non métier (ex : email syntaxique)
- Throttling / Debouncing pour limiter certaines actions
- Orchestration de plusieurs repositories
- Logging applicatif
- Règles propres à l'usage mais pas strictement métier

##### 5. Définir des interfaces orientées cas d'usage

L'UI n'appelle jamais directement un repository. Elle appelle un **service d'application** :

```dart
abstract interface class SourceValidationQuery {
  Future<SourceValidationResultDto> execute(SourceUrl url);
}
```

#### 📁 Structure recommandée

```
core/application/
├── usecases/
│   ├── validate_source_url.usecase.dart
│   ├── fetch_sources.usecase.dart
│   └── ...
├── dtos/
│   ├── source.dto.dart
│   └── source_validation_result.dto.dart
├── services/
│   ├── source_application.service.dart
│   └── ...
```

#### 📌 Usecases

Chaque fichier = un cas d'usage.

```dart
class ValidateSourceUrlUseCase {
  final SourceRepository repo;
  
  ValidateSourceUrlUseCase(this.repo);

  Future<SourceValidationResultDto> execute(String url) async {
    try {
      final source = SourceUrl(url);
      final result = await repo.validateUrl(source);
      return SourceValidationResultDto.fromDomain(result);
    } on InvalidSourceUrlException {
      return SourceValidationResultDto.invalidFormat();
    }
  }
}
```

#### 📌 DTOs

Ils traduisent Domain → UI. L'UI ne voit jamais les entités Domain.

```dart
class SourceValidationResultDto {
  final bool isValid;
  final String? message;

  SourceValidationResultDto(this.isValid, this.message);

  factory SourceValidationResultDto.fromDomain(SourceValidationResult domain) {
    return SourceValidationResultDto(
      domain.success,
      domain.reason,
    );
  }

  factory SourceValidationResultDto.invalidFormat() =>
      SourceValidationResultDto(false, "URL invalide");
}
```

#### 📌 Services Applicatifs

Ils regroupent plusieurs usecases cohérents.

```dart
class SourceApplicationService {
  final ValidateSourceUrlUseCase validateUrl;
  final FetchSourcesUseCase fetchSources;

  SourceApplicationService({
    required this.validateUrl,
    required this.fetchSources,
  });
}
```

**Caractéristiques** :
- Dépend uniquement de la couche **Domain**
- Contient la logique d'orchestration, pas de logique technique
- **Ne dépend pas de Riverpod** : les cas d'usage sont testables sans framework
- Consommé par l'UI via des providers créés dans Infrastructure

**Règles strictes** :
- ❌ Pas de Flutter
- ❌ Pas d'HTTP
- ✅ Peut faire du mapping (Domain → DTO)
- ✅ Peut orchestrer plusieurs repositories
- ✅ Peut gérer les erreurs
- ✅ Peut contenir des règles propres à l'application (mais pas métier)
- ✅ Testable sans framework

---

### 🔌 **Infrastructure** (`lib/infrastructure/`)

**Responsabilité** : Implémente les adaptateurs vers les systèmes externes.

**Contenu** :
- `source/` : Implémentations concrètes des repositories
  - `http.source.repository.dart` : Repository HTTP (production)
  - `in_memory.source.repository.dart` : Repository en mémoire (dev/test)
- `providers/` : Providers Riverpod qui retournent les implémentations adaptées à l'environnement

**Caractéristiques** :
- Dépend uniquement de **Domain**
- Implémente les interfaces définies par Domain
- Gère les détails techniques (HTTP, caches, stockage…)
- **Seule couche où Riverpod est utilisé** pour assembler les dépendances

**Règles strictes** :
- ✅ HTTP, DB, fichiers
- ✅ Implémentations techniques
- ✅ Providers Riverpod pour assembler les dépendances

---

### 🎨 **UI** (`lib/ui/`)

**Responsabilité** : Interface utilisateur Flutter.

#### 📁 Structure recommandée

```
ui/
└── pages/
    └── nom_feature/              # Dossier par feature (snake_case)
        ├── nom.page.dart         # Page principale
        ├── widgets/              # Widgets spécifiques à cette page
        │   ├── nom_widget.widget.dart
        │   └── autre.widget.dart
        └── providers/            # Providers UI locaux (si nécessaire)
            └── nom.provider.dart
```

**Contenu** :
- `pages/` : Dossiers organisés par feature/page
- `nom.page.dart` : Pages (écrans complets)
- `widgets/` : Widgets réutilisables spécifiques à une page
- `providers/` : Providers UI locaux (état de l'écran)

**Caractéristiques** :
- **Ne dépend que de la couche Application**
- Accède aux cas d'usage via des providers exposant les interfaces Domain
- Ne connaît jamais les implémentations concrètes (HTTP, in-memory, etc.)
- Aucune logique métier : elle se limite à l'affichage et aux interactions

**Règles strictes** :
- ✅ Appelle uniquement des usecases ou ApplicationService
- ✅ Contient de la logique d'affichage seulement
- ✅ Les pages sont nommées `nom.page.dart`
- ✅ Les widgets sont dans un sous-dossier `widgets/` et nommés `nom.widget.dart`
- ❌ Ne connaît pas Domain (ou très peu)

---

### 🔧 **Shared** (`lib/shared/`)

**Responsabilité** : Utilitaires et informations globales.

**Contenu** :
- `dependency_injection.dart` : Choix d'environnement (prod, dev, test)
- Constantes, helpers, etc.

---

## Flux de données et dépendances

### 📐 Direction des dépendances

```

UI → Application → Domain ← Infrastructure

```

**Principes :**

1. **Domain** ne dépend de personne  
2. **Application** dépend uniquement de Domain  
3. **Infrastructure** dépend uniquement de Domain  
4. **UI** dépend uniquement d'Application (et des interfaces Domain via les providers)

> L'UI ne connaît jamais les implémentations concrètes (ex: `HttpSourceRepository`).

---

## 🔁 Flux de données : exemple

### 1. Validation d'URL de source

```
UI
→ SourceApplicationService.validateUrl.execute() (Application)
→ SourceRepository (interface Domain)
→ HttpSourceRepository / InMemorySourceRepository (Infrastructure)
```

**Étapes :**

1. L'UI invoque le service applicatif `SourceApplicationService.validateUrl.execute()`
2. Le usecase appelle `SourceRepository.validateUrl()`
3. Riverpod injecte l'implémentation correcte :
   - Production → `HttpSourceRepository`
   - Dev/Test → `InMemorySourceRepository`
4. Le usecase transforme le résultat Domain en DTO
5. L'UI reçoit un `SourceValidationResultDto`

### 2. 🧩 Injection de dépendances (DI)

Les implémentations concrètes et services applicatifs sont fournis via Riverpod dans `infrastructure/providers/` :

```dart
// infrastructure/providers/source.repository_provider.dart
@riverpod
SourceRepository sourceRepository(Ref ref) {
  if (DependencyInjection.isProduction) {
    return HttpSourceRepository();
  }
  return InMemorySourceRepository();
}
```

```dart
// infrastructure/providers/source.service_provider.dart
@riverpod
SourceApplicationService sourceService(Ref ref) {
  final repo = ref.watch(sourceRepositoryProvider);
  return SourceApplicationService(
    validateUrl: ValidateSourceUrlUseCase(repo),
    fetchSources: FetchSourcesUseCase(repo),
  );
}
```

**Rappel :**

* L'UI consomme uniquement des providers retournant **des services applicatifs ou des usecases**.
* Les implémentations concrètes sont invisibles à l'UI.
* L'UI ne voit jamais les entités Domain, seulement les DTOs.

---

## Conventions de nommage

### 📄 Fichiers

* **Domain** : `nom.interface.dart`
  ex : `source.repository.dart`
* **Application** :
  * Usecases : `nom.usecase.dart` (ex : `validate_source_url.usecase.dart`)
  * DTOs : `nom.dto.dart` (ex : `source_validation_result.dto.dart`)
  * Services : `nom_application.service.dart` (ex : `source_application.service.dart`)
* **Infrastructure** : `type.nom.repository.dart`
  ex : `http.source.repository.dart`
* **Providers** : `nom.what_provider.dart`
  ex : `source.repository_provider.dart`
* **UI** :
  * Pages : `nom.page.dart` (ex : `home.page.dart`, `settings.page.dart`)
  * Widgets : `nom.widget.dart` dans un dossier `widgets/` (ex : `widgets/song_card.widget.dart`)
  * Providers UI : `nom.provider.dart` (ex : `search.provider.dart`)

### 🧱 Classes

* **Interfaces** : `NomRepository`, `NomService`
* **Implémentations** : `TypeNomRepository`, `TypeNomService`
* **Usecases** : `NomUseCase`
* **DTOs** : `NomDto`
* **Modèles Domain** : `Nom`
* **Services Applicatifs** : `NomApplicationService`

## Bonnes pratiques pour les contributeurs

### ✅ À faire

1. Respecter strictement la direction des dépendances
2. Toujours coder contre des **interfaces**, jamais des implémentations
3. Utiliser Riverpod pour l'injection (uniquement dans Infrastructure)
4. Tester chaque couche indépendamment
5. Séparer logique métier (Domain) et orchestration (Application)
6. Utiliser des DTOs pour communiquer entre Application et UI
7. Centraliser la gestion des erreurs dans les usecases
8. **Utiliser uniquement des imports absolus** : tous les imports doivent commencer par `package:songbook/` (jamais de chemins relatifs avec `../`)

### ❌ À éviter

1. Importer des implémentations concrètes dans Application ou UI
2. Mettre de la logique métier dans l'UI
3. Créer des dépendances circulaires
4. Accéder directement aux données sans passer par un repository
5. Utiliser Riverpod en dehors de la couche Infrastructure
6. Exposer des entités Domain directement à l'UI
7. **Utiliser des imports relatifs** : ne jamais utiliser `../` dans les imports (toujours préférer `package:songbook/`)

### ➕ Ajout d'une nouvelle fonctionnalité

1. **Définir l'entité** dans `core/domain/model/`
2. **Créer l'interface** correspondante dans `core/domain/services/`
3. **Implémenter le repository** dans `infrastructure/`
4. **Créer le DTO** dans `core/application/dtos/`
5. **Créer le usecase** dans `core/application/usecases/`
6. **Mettre à jour ou créer le service applicatif** dans `core/application/services/`
7. **Créer ou modifier le provider** dans `infrastructure/providers/`
8. **Utiliser dans l'UI** via Riverpod

### 🧪 Tests

L'application n'est pas testé pour le moment.
