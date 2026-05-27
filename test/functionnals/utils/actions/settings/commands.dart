import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/core/domain/model/theme_mode.dart';

import '../../types.dart';
import 'finders.dart';

/// Commande pour sélectionner un thème via le SegmentedButton.
class TapThemeSegmentCommand extends FluentCommand {
  final WidgetTester tester;
  final String label;

  TapThemeSegmentCommand(this.tester, this.label);

  @override
  Future<void> execute() async {
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }
}

/// Commande pour vérifier quel thème est sélectionné.
class ExpectThemeSelectedCommand extends FluentCommand {
  final SettingsPageFinders finders;
  final AppThemeMode expectedMode;

  ExpectThemeSelectedCommand(this.finders, this.expectedMode);

  @override
  Future<void> execute() async {
    final segmentedButton = finders.themeSegmentedButton;
    expect(segmentedButton, findsOneWidget);

    final widget =
        segmentedButton.evaluate().first.widget as SegmentedButton<AppThemeMode>;
    expect(
      widget.selected,
      equals({expectedMode}),
      reason: 'Theme should be ${expectedMode.name}',
    );
  }
}

/// Commande pour vérifier que le champ URL affiche une valeur donnée.
class ExpectBackendUrlCommand extends FluentCommand {
  final SettingsPageFinders finders;
  final String expectedUrl;

  ExpectBackendUrlCommand(this.finders, this.expectedUrl);

  @override
  Future<void> execute() async {
    final textField =
        finders.backendUrlField.evaluate().first.widget as TextField;
    expect(
      textField.controller?.text,
      equals(expectedUrl),
      reason: 'Backend URL should be $expectedUrl',
    );
  }
}

/// Commande pour taper sur le bouton "Modifier" de l'URL.
class TapBackendUrlEditCommand extends FluentCommand {
  final WidgetTester tester;
  final SettingsPageFinders finders;

  TapBackendUrlEditCommand(this.tester, this.finders);

  @override
  Future<void> execute() async {
    await tester.tap(finders.backendUrlEditButton);
    await tester.pumpAndSettle();
  }
}

/// Commande pour taper sur le bouton "Annuler" de l'URL.
class TapBackendUrlCancelCommand extends FluentCommand {
  final WidgetTester tester;
  final SettingsPageFinders finders;

  TapBackendUrlCancelCommand(this.tester, this.finders);

  @override
  Future<void> execute() async {
    await tester.tap(finders.backendUrlCancelButton);
    await tester.pumpAndSettle();
  }
}

/// Commande pour saisir une URL dans le champ backend.
class EnterBackendUrlCommand extends FluentCommand {
  final WidgetTester tester;
  final SettingsPageFinders finders;
  final String url;

  EnterBackendUrlCommand(this.tester, this.finders, this.url);

  @override
  Future<void> execute() async {
    await tester.enterText(finders.backendUrlField, url);
    await tester.pumpAndSettle();
  }
}

/// Commande pour taper sur le bouton "Sauvegarder" de l'URL.
class TapBackendUrlSaveCommand extends FluentCommand {
  final WidgetTester tester;
  final SettingsPageFinders finders;

  TapBackendUrlSaveCommand(this.tester, this.finders);

  @override
  Future<void> execute() async {
    await tester.tap(finders.backendUrlSaveButton);
    await tester.pumpAndSettle();
  }
}

/// Commande pour vérifier que le champ URL est en lecture seule.
class ExpectBackendUrlReadonlyCommand extends FluentCommand {
  final SettingsPageFinders finders;

  ExpectBackendUrlReadonlyCommand(this.finders);

  @override
  Future<void> execute() async {
    final textField =
        finders.backendUrlField.evaluate().first.widget as TextField;
    expect(
      textField.readOnly,
      isTrue,
      reason: 'Backend URL field should be read-only',
    );
  }
}

/// Commande pour vérifier que le champ URL est éditable.
class ExpectBackendUrlEditableCommand extends FluentCommand {
  final SettingsPageFinders finders;

  ExpectBackendUrlEditableCommand(this.finders);

  @override
  Future<void> execute() async {
    final textField =
        finders.backendUrlField.evaluate().first.widget as TextField;
    expect(
      textField.readOnly,
      isFalse,
      reason: 'Backend URL field should be editable',
    );
  }
}

/// Commande pour vérifier que le bouton "Sauvegarder" est activé.
class ExpectSaveButtonEnabledCommand extends FluentCommand {
  final SettingsPageFinders finders;

  ExpectSaveButtonEnabledCommand(this.finders);

  @override
  Future<void> execute() async {
    final button = finders.backendUrlSaveButton.evaluate().first.widget
        as TextButton;
    expect(
      button.onPressed,
      isNotNull,
      reason: 'Save button should be enabled',
    );
  }
}

/// Commande pour vérifier que le bouton "Sauvegarder" est désactivé.
class ExpectSaveButtonDisabledCommand extends FluentCommand {
  final SettingsPageFinders finders;

  ExpectSaveButtonDisabledCommand(this.finders);

  @override
  Future<void> execute() async {
    final button = finders.backendUrlSaveButton.evaluate().first.widget
        as TextButton;
    expect(
      button.onPressed,
      isNull,
      reason: 'Save button should be disabled',
    );
  }
}

/// Commande pour taper sur le bouton "Vider la base de données".
class TapClearDatabaseCommand extends FluentCommand {
  final WidgetTester tester;
  final SettingsPageFinders finders;

  TapClearDatabaseCommand(this.tester, this.finders);

  @override
  Future<void> execute() async {
    await tester.tap(finders.clearDatabaseButton);
    await tester.pumpAndSettle();
  }
}

/// Commande pour taper sur "Supprimer" dans le dialog de confirmation.
class TapConfirmClearDatabaseCommand extends FluentCommand {
  final WidgetTester tester;
  final SettingsPageFinders finders;

  TapConfirmClearDatabaseCommand(this.tester, this.finders);

  @override
  Future<void> execute() async {
    await tester.tap(finders.clearDatabaseConfirmButton);
    await tester.pumpAndSettle();
  }
}

/// Commande pour taper sur "Annuler" dans le dialog de confirmation.
class TapCancelClearDatabaseCommand extends FluentCommand {
  final WidgetTester tester;
  final SettingsPageFinders finders;

  TapCancelClearDatabaseCommand(this.tester, this.finders);

  @override
  Future<void> execute() async {
    await tester.tap(finders.clearDatabaseCancelButton);
    await tester.pumpAndSettle();
  }
}

/// Commande pour vérifier que le dialog de confirmation est affiché.
class ExpectClearDatabaseDialogVisibleCommand extends FluentCommand {
  @override
  Future<void> execute() async {
    expect(
      find.text('Vider la base de données'),
      findsNWidgets(2), // titre du dialog + bouton
      reason: 'Clear database confirmation dialog should be visible',
    );
  }
}

/// Commande pour vérifier que le dialog de confirmation est fermé.
class ExpectClearDatabaseDialogDismissedCommand extends FluentCommand {
  @override
  Future<void> execute() async {
    // Le dialog est fermé, on ne devrait trouver qu'un seul texte (le bouton)
    expect(
      find.text('Vider la base de données'),
      findsOneWidget,
      reason: 'Clear database dialog should be dismissed',
    );
  }
}

/// Commande pour vérifier que le bouton "Modifier" de l'URL est visible.
class ExpectBackendUrlEditButtonVisibleCommand extends FluentCommand {
  final SettingsPageFinders finders;

  ExpectBackendUrlEditButtonVisibleCommand(this.finders);

  @override
  Future<void> execute() async {
    expect(
      finders.backendUrlEditButton,
      findsOneWidget,
      reason: 'Backend URL edit button should be visible',
    );
  }
}

/// Commande pour vérifier que le bouton "Modifier" de l'URL est absent.
class ExpectBackendUrlEditButtonAbsentCommand extends FluentCommand {
  final SettingsPageFinders finders;

  ExpectBackendUrlEditButtonAbsentCommand(this.finders);

  @override
  Future<void> execute() async {
    expect(
      finders.backendUrlEditButton,
      findsNothing,
      reason: 'Backend URL edit button should not be visible in edit mode',
    );
  }
}
