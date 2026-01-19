# Fluent Functional Testing Framework

Architecture de tests fonctionnels basée sur une API fluente avec exécution différée des commandes.

## Principes Fondamentaux

### Exécution Différée

Les actions de test ne s'exécutent pas immédiatement. Elles s'accumulent dans une file de commandes, puis s'exécutent séquentiellement lors de l'appel à `execute()`.

```dart
await pageObjects
    .doSomething()      // Ajoute une commande
    .doSomethingElse()  // Ajoute une autre commande
    .expectResult()     // Ajoute une assertion
    .execute();         // Exécute tout séquentiellement
```

### Navigation Type-Safe

Chaque méthode de navigation retourne un type `Actions` spécifique au contexte. Cela garantit que seules les méthodes valides pour une page donnée sont disponibles.

```dart
await startInPageA(tester)
    .performActionOnPageA()
    .navigateToPageB()          // Retourne PageBActions
    .performActionOnPageB()     // Méthodes de PageA non disponibles
    .execute();
```

## Architecture 3 Couches

Chaque page est organisée en trois couches distinctes :

```
page/
├── page.finders.dart    # Localisation des éléments
├── page.commands.dart   # Actions unitaires
└── page.actions.dart    # API fluente
```

### Finders - Localisation des Éléments

Encapsulent les appels `find.*` avec des propriétés nommées.

```dart
class PageFinder {
  final WidgetTester tester;
  PageFinder(this.tester);

  // Finders simples
  Finder get submitButton => find.byKey(const Key('submit_button'));
  Finder get emailField => find.byKey(const Key('email_field'));

  // Finders paramétrés
  Finder findItemByName(String name) => find.text(name);

  // Getters d'état
  String get currentEmail {
    final widget = tester.widget<TextField>(emailField);
    return widget.controller?.text ?? '';
  }

  bool get isLoading => find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
}
```

### Commands - Actions Unitaires

Chaque interaction UI est une classe `FluentCommand` distincte.

```dart
abstract class FluentCommand {
  Future<void> execute();
}

class TapButtonCommand extends FluentCommand {
  final WidgetTester tester;
  final Finder finder;

  TapButtonCommand(this.tester, this.finder);

  @override
  Future<void> execute() async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }
}

class EnterTextCommand extends FluentCommand {
  final WidgetTester tester;
  final Finder finder;
  final String text;

  EnterTextCommand(this.tester, this.finder, this.text);

  @override
  Future<void> execute() async {
    await tester.tap(finder);
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }
}

class ExpectVisibleCommand extends FluentCommand {
  final WidgetTester tester;
  final Finder finder;
  final String description;

  ExpectVisibleCommand(this.tester, this.finder, this.description);

  @override
  Future<void> execute() async {
    expect(finder, findsOneWidget, reason: '$description should be visible');
  }
}
```

### Actions - API Fluente

Orchestrent les commandes pour fournir une API expressive.

```dart
class PageActions extends FluentActionsBase {
  final PageFinder _finder;

  PageActions(super.navigation, super.tester)
      : _finder = PageFinder(tester);

  // Actions retournant this pour le chaînage
  PageActions enterEmail(String email) {
    addCommand(EnterTextCommand(tester, _finder.emailField, email));
    return this;
  }

  PageActions tapSubmit() {
    addCommand(TapButtonCommand(tester, _finder.submitButton));
    return this;
  }

  // Assertions
  PageActions expectEmailIs(String expected) {
    addCommand(ExpectValueCommand(
      () => _finder.currentEmail,
      expected,
      'Email field',
    ));
    return this;
  }

  PageActions expectErrorVisible() {
    addCommand(ExpectVisibleCommand(tester, _finder.errorMessage, 'Error'));
    return this;
  }

  // Navigation vers autre contexte
  OtherPageActions goToOtherPage() {
    addCommand(NavigateCommand(tester, '/other'));
    return OtherPageActions(navigation, tester)..commands.addAll(commands);
  }
}
```

## Classes de Base

### Interface de Navigation

```dart
abstract class IFluentNavigation {
  PageAActions get pageA;
  PageBActions get pageB;
  // ... autres pages
}

abstract class FluentCommand {
  Future<void> execute();
}
```

### Base des Actions

```dart
abstract class FluentActionsBase {
  final IFluentNavigation navigation;
  final WidgetTester tester;
  final List<FluentCommand> commands = [];

  FluentActionsBase(this.navigation, this.tester);

  void addCommand(FluentCommand command) {
    commands.add(command);
  }

  Future<void> execute() async {
    for (final command in commands) {
      await command.execute();
    }
    commands.clear();
  }

  // Méthodes de navigation communes
  PageAActions goToPageA() {
    addCommand(NavigateToPageACommand(tester));
    return navigation.pageA..commands.addAll(commands);
  }
}
```

### Façade Principale

```dart
class PageObjects implements IFluentNavigation {
  final WidgetTester tester;

  PageObjects(this.tester);

  @override
  PageAActions get pageA => PageAActions(this, tester);

  @override
  PageBActions get pageB => PageBActions(this, tester);
}
```

## Helpers d'Initialisation

```dart
Future<PageObjects> startApp(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [/* mocks */],
      child: const MyApp(),
    ),
  );
  await tester.pumpAndSettle();
  return PageObjects(tester);
}

Future<PageAActions> startInPageA(WidgetTester tester) async {
  final pageObjects = await startApp(tester);
  // Navigation initiale si nécessaire
  return pageObjects.pageA;
}

Future<PageBActions> startInPageB(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: const PageBPage(),
    ),
  );
  await tester.pumpAndSettle();
  return PageBActions(PageObjects(tester), tester);
}
```

## Structure de Répertoires

```
test/functionnals/
├── utils/
│   ├── base.dart              # FluentActionsBase
│   ├── types.dart             # Interfaces
│   ├── page_objects.dart      # Façade PageObjects
│   ├── pumps.dart             # Helpers d'initialisation
│   ├── index.dart             # Exports
│   └── actions/
│       ├── page_a/
│       │   ├── page_a.finders.dart
│       │   ├── page_a.commands.dart
│       │   └── page_a.actions.dart
│       └── page_b/
│           ├── page_b.finders.dart
│           ├── page_b.commands.dart
│           └── page_b.actions.dart
└── tests/
    ├── page_a/
    │   └── page_a.page_test.dart
    └── page_b/
        └── page_b.page_test.dart
```

## Exemple de Test Complet

```dart
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Page A', () {
    testWidgets('should validate email format', (tester) async {
      await (await startInPageA(tester))
          .enterEmail('invalid-email')
          .tapSubmit()
          .expectErrorVisible()
          .execute();
    });

    testWidgets('should navigate to Page B on success', (tester) async {
      await (await startInPageA(tester))
          .enterEmail('valid@email.com')
          .enterPassword('password123')
          .tapSubmit()
          .goToPageB()
          .expectWelcomeMessageVisible()
          .execute();
    });
  });
}
```

## Commandes Utilitaires Réutilisables

### Attente et Scroll

```dart
class ScrollUntilVisibleCommand extends FluentCommand {
  final WidgetTester tester;
  final Finder finder;
  final Finder scrollable;

  ScrollUntilVisibleCommand(this.tester, this.finder, this.scrollable);

  @override
  Future<void> execute() async {
    await tester.scrollUntilVisible(finder, 100, scrollable: scrollable);
    await tester.pumpAndSettle();
  }
}

class WaitForCommand extends FluentCommand {
  final WidgetTester tester;
  final Duration duration;

  WaitForCommand(this.tester, this.duration);

  @override
  Future<void> execute() async {
    await tester.pump(duration);
  }
}
```

### Assertions Génériques

```dart
class ExpectFinderCommand extends FluentCommand {
  final Finder finder;
  final Matcher matcher;
  final String description;

  ExpectFinderCommand(this.finder, this.matcher, this.description);

  @override
  Future<void> execute() async {
    expect(finder, matcher, reason: description);
  }
}

class ExpectValueCommand<T> extends FluentCommand {
  final T Function() getValue;
  final T expected;
  final String description;

  ExpectValueCommand(this.getValue, this.expected, this.description);

  @override
  Future<void> execute() async {
    expect(getValue(), expected, reason: description);
  }
}
```

## Avantages de cette Architecture

| Aspect | Bénéfice |
|--------|----------|
| **Lisibilité** | Tests lisibles comme du langage naturel |
| **Maintenabilité** | Séparation claire des responsabilités |
| **Type-Safety** | Erreurs détectées à la compilation |
| **Réutilisabilité** | Commandes et finders partagés |
| **Debugging** | Exécution séquentielle facilite l'identification des erreurs |
| **Scalabilité** | Ajout de features sans impact sur l'existant |

## Bonnes Pratiques

1. **Un Finder par élément UI** - Éviter la duplication des sélecteurs
2. **Une Command par action atomique** - Garder les commandes simples et réutilisables
3. **Nommage explicite** - `expectErrorMessageVisible()` plutôt que `checkError()`
4. **Assertions dans les Actions** - Intégrer les vérifications dans l'API fluente
5. **Initialisation contextuelle** - Créer des helpers `startIn*` pour chaque contexte de test
6. **Keys explicites** - Utiliser des `Key` pour les éléments testés plutôt que `find.byType`
# Fluent Functional Testing Framework

Architecture de tests fonctionnels basée sur une API fluente avec exécution différée des commandes.

## Principes Fondamentaux

### Exécution Différée

Les actions de test ne s'exécutent pas immédiatement. Elles s'accumulent dans une file de commandes, puis s'exécutent séquentiellement lors de l'appel à `execute()`.

```dart
await pageObjects
    .doSomething()      // Ajoute une commande
    .doSomethingElse()  // Ajoute une autre commande
    .expectResult()     // Ajoute une assertion
    .execute();         // Exécute tout séquentiellement
```

### Navigation Type-Safe

Chaque méthode de navigation retourne un type `Actions` spécifique au contexte. Cela garantit que seules les méthodes valides pour une page donnée sont disponibles.

```dart
await startInPageA(tester)
    .performActionOnPageA()
    .navigateToPageB()          // Retourne PageBActions
    .performActionOnPageB()     // Méthodes de PageA non disponibles
    .execute();
```

## Architecture 3 Couches

Chaque page est organisée en trois couches distinctes :

```
page/
├── page.finders.dart    # Localisation des éléments
├── page.commands.dart   # Actions unitaires
└── page.actions.dart    # API fluente
```

### Finders - Localisation des Éléments

Encapsulent les appels `find.*` avec des propriétés nommées.

```dart
class PageFinder {
  final WidgetTester tester;
  PageFinder(this.tester);

  // Finders simples
  Finder get submitButton => find.byKey(const Key('submit_button'));
  Finder get emailField => find.byKey(const Key('email_field'));

  // Finders paramétrés
  Finder findItemByName(String name) => find.text(name);

  // Getters d'état
  String get currentEmail {
    final widget = tester.widget<TextField>(emailField);
    return widget.controller?.text ?? '';
  }

  bool get isLoading => find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
}
```

### Commands - Actions Unitaires

Chaque interaction UI est une classe `FluentCommand` distincte.

```dart
abstract class FluentCommand {
  Future<void> execute();
}

class TapButtonCommand extends FluentCommand {
  final WidgetTester tester;
  final Finder finder;

  TapButtonCommand(this.tester, this.finder);

  @override
  Future<void> execute() async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }
}

class EnterTextCommand extends FluentCommand {
  final WidgetTester tester;
  final Finder finder;
  final String text;

  EnterTextCommand(this.tester, this.finder, this.text);

  @override
  Future<void> execute() async {
    await tester.tap(finder);
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }
}

class ExpectVisibleCommand extends FluentCommand {
  final WidgetTester tester;
  final Finder finder;
  final String description;

  ExpectVisibleCommand(this.tester, this.finder, this.description);

  @override
  Future<void> execute() async {
    expect(finder, findsOneWidget, reason: '$description should be visible');
  }
}
```

### Actions - API Fluente

Orchestrent les commandes pour fournir une API expressive.

```dart
class PageActions extends FluentActionsBase {
  final PageFinder _finder;

  PageActions(super.navigation, super.tester)
      : _finder = PageFinder(tester);

  // Actions retournant this pour le chaînage
  PageActions enterEmail(String email) {
    addCommand(EnterTextCommand(tester, _finder.emailField, email));
    return this;
  }

  PageActions tapSubmit() {
    addCommand(TapButtonCommand(tester, _finder.submitButton));
    return this;
  }

  // Assertions
  PageActions expectEmailIs(String expected) {
    addCommand(ExpectValueCommand(
      () => _finder.currentEmail,
      expected,
      'Email field',
    ));
    return this;
  }

  PageActions expectErrorVisible() {
    addCommand(ExpectVisibleCommand(tester, _finder.errorMessage, 'Error'));
    return this;
  }

  // Navigation vers autre contexte
  OtherPageActions goToOtherPage() {
    addCommand(NavigateCommand(tester, '/other'));
    return OtherPageActions(navigation, tester)..commands.addAll(commands);
  }
}
```

## Classes de Base

### Interface de Navigation

```dart
abstract class IFluentNavigation {
  PageAActions get pageA;
  PageBActions get pageB;
  // ... autres pages
}

abstract class FluentCommand {
  Future<void> execute();
}
```

### Base des Actions

```dart
abstract class FluentActionsBase {
  final IFluentNavigation navigation;
  final WidgetTester tester;
  final List<FluentCommand> commands = [];

  FluentActionsBase(this.navigation, this.tester);

  void addCommand(FluentCommand command) {
    commands.add(command);
  }

  Future<void> execute() async {
    for (final command in commands) {
      await command.execute();
    }
    commands.clear();
  }

  // Méthodes de navigation communes
  PageAActions goToPageA() {
    addCommand(NavigateToPageACommand(tester));
    return navigation.pageA..commands.addAll(commands);
  }
}
```

### Façade Principale

```dart
class PageObjects implements IFluentNavigation {
  final WidgetTester tester;

  PageObjects(this.tester);

  @override
  PageAActions get pageA => PageAActions(this, tester);

  @override
  PageBActions get pageB => PageBActions(this, tester);
}
```

## Helpers d'Initialisation

```dart
Future<PageObjects> startApp(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [/* mocks */],
      child: const MyApp(),
    ),
  );
  await tester.pumpAndSettle();
  return PageObjects(tester);
}

Future<PageAActions> startInPageA(WidgetTester tester) async {
  final pageObjects = await startApp(tester);
  // Navigation initiale si nécessaire
  return pageObjects.pageA;
}

Future<PageBActions> startInPageB(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: const PageBPage(),
    ),
  );
  await tester.pumpAndSettle();
  return PageBActions(PageObjects(tester), tester);
}
```

## Structure de Répertoires

```
test/functionnals/
├── utils/
│   ├── base.dart              # FluentActionsBase
│   ├── types.dart             # Interfaces
│   ├── page_objects.dart      # Façade PageObjects
│   ├── pumps.dart             # Helpers d'initialisation
│   ├── index.dart             # Exports
│   └── actions/
│       ├── page_a/
│       │   ├── page_a.finders.dart
│       │   ├── page_a.commands.dart
│       │   └── page_a.actions.dart
│       └── page_b/
│           ├── page_b.finders.dart
│           ├── page_b.commands.dart
│           └── page_b.actions.dart
└── tests/
    ├── page_a/
    │   └── page_a.page_test.dart
    └── page_b/
        └── page_b.page_test.dart
```

## Exemple de Test Complet

```dart
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Page A', () {
    testWidgets('should validate email format', (tester) async {
      await (await startInPageA(tester))
          .enterEmail('invalid-email')
          .tapSubmit()
          .expectErrorVisible()
          .execute();
    });

    testWidgets('should navigate to Page B on success', (tester) async {
      await (await startInPageA(tester))
          .enterEmail('valid@email.com')
          .enterPassword('password123')
          .tapSubmit()
          .goToPageB()
          .expectWelcomeMessageVisible()
          .execute();
    });
  });
}
```

## Commandes Utilitaires Réutilisables

### Attente et Scroll

```dart
class ScrollUntilVisibleCommand extends FluentCommand {
  final WidgetTester tester;
  final Finder finder;
  final Finder scrollable;

  ScrollUntilVisibleCommand(this.tester, this.finder, this.scrollable);

  @override
  Future<void> execute() async {
    await tester.scrollUntilVisible(finder, 100, scrollable: scrollable);
    await tester.pumpAndSettle();
  }
}

class WaitForCommand extends FluentCommand {
  final WidgetTester tester;
  final Duration duration;

  WaitForCommand(this.tester, this.duration);

  @override
  Future<void> execute() async {
    await tester.pump(duration);
  }
}
```

### Assertions Génériques

```dart
class ExpectFinderCommand extends FluentCommand {
  final Finder finder;
  final Matcher matcher;
  final String description;

  ExpectFinderCommand(this.finder, this.matcher, this.description);

  @override
  Future<void> execute() async {
    expect(finder, matcher, reason: description);
  }
}

class ExpectValueCommand<T> extends FluentCommand {
  final T Function() getValue;
  final T expected;
  final String description;

  ExpectValueCommand(this.getValue, this.expected, this.description);

  @override
  Future<void> execute() async {
    expect(getValue(), expected, reason: description);
  }
}
```

## Avantages de cette Architecture

| Aspect | Bénéfice |
|--------|----------|
| **Lisibilité** | Tests lisibles comme du langage naturel |
| **Maintenabilité** | Séparation claire des responsabilités |
| **Type-Safety** | Erreurs détectées à la compilation |
| **Réutilisabilité** | Commandes et finders partagés |
| **Debugging** | Exécution séquentielle facilite l'identification des erreurs |
| **Scalabilité** | Ajout de features sans impact sur l'existant |

## Bonnes Pratiques

1. **Un Finder par élément UI** - Éviter la duplication des sélecteurs
2. **Une Command par action atomique** - Garder les commandes simples et réutilisables
3. **Nommage explicite** - `expectErrorMessageVisible()` plutôt que `checkError()`
4. **Assertions dans les Actions** - Intégrer les vérifications dans l'API fluente
5. **Initialisation contextuelle** - Créer des helpers `startIn*` pour chaque contexte de test
6. **Keys explicites** - Utiliser des `Key` pour les éléments testés plutôt que `find.byType`
