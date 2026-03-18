import 'package:flutter_test/flutter_test.dart';

import '../../types.dart';
import 'finders.dart';

/// Vérifie que le titre est correct.
class ExpectEditTitleCommand extends FluentCommand {
  final String expectedTitle;

  ExpectEditTitleCommand(this.expectedTitle);

  @override
  Future<void> execute() async {
    expect(
      find.text(expectedTitle),
      findsOneWidget,
      reason: 'Title should be "$expectedTitle"',
    );
  }
}

/// Vérifie l'état vide.
class ExpectEditEmptyCommand extends FluentCommand {
  final SongListEditPageFinders finders;

  ExpectEditEmptyCommand(this.finders);

  @override
  Future<void> execute() async {
    expect(
      finders.emptyState,
      findsOneWidget,
      reason: 'Empty state should be visible',
    );
  }
}

/// Vérifie que la liste réordonnable est visible.
class ExpectReorderableListVisibleCommand extends FluentCommand {
  final SongListEditPageFinders finders;

  ExpectReorderableListVisibleCommand(this.finders);

  @override
  Future<void> execute() async {
    expect(
      finders.reorderableList,
      findsOneWidget,
      reason: 'Reorderable list should be visible',
    );
  }
}

/// Vérifie qu'un texte est visible.
class ExpectEditTextVisibleCommand extends FluentCommand {
  final String text;

  ExpectEditTextVisibleCommand(this.text);

  @override
  Future<void> execute() async {
    expect(
      find.text(text),
      findsWidgets,
      reason: 'Text "$text" should be visible',
    );
  }
}

/// Vérifie qu'un texte n'est pas visible.
class ExpectEditTextNotVisibleCommand extends FluentCommand {
  final String text;

  ExpectEditTextNotVisibleCommand(this.text);

  @override
  Future<void> execute() async {
    expect(
      find.text(text),
      findsNothing,
      reason: 'Text "$text" should not be visible',
    );
  }
}

/// Tape sur le bouton sauvegarder.
class TapSaveButtonCommand extends FluentCommand {
  final WidgetTester tester;
  final SongListEditPageFinders finders;

  TapSaveButtonCommand(this.tester, this.finders);

  @override
  Future<void> execute() async {
    await tester.tap(finders.saveButton);
    await tester.pumpAndSettle();
  }
}

/// Tape sur le FAB ajouter.
class TapAddSongFabCommand extends FluentCommand {
  final WidgetTester tester;
  final SongListEditPageFinders finders;

  TapAddSongFabCommand(this.tester, this.finders);

  @override
  Future<void> execute() async {
    await tester.tap(finders.addSongFab);
    await tester.pumpAndSettle();
  }
}

/// Tape sur le sélecteur de date/heure.
class TapDateTimePickerCommand extends FluentCommand {
  final WidgetTester tester;
  final SongListEditPageFinders finders;

  TapDateTimePickerCommand(this.tester, this.finders);

  @override
  Future<void> execute() async {
    await tester.tap(finders.dateTimePicker);
    await tester.pumpAndSettle();
  }
}

/// Tape sur le bouton supprimer une entrée à un index.
class TapRemoveEntryCommand extends FluentCommand {
  final WidgetTester tester;
  final SongListEditPageFinders finders;
  final int index;

  TapRemoveEntryCommand(this.tester, this.finders, this.index);

  @override
  Future<void> execute() async {
    await tester.tap(finders.removeButtonAt(index));
    await tester.pumpAndSettle();
  }
}

/// Confirme le dialogue de modifications non sauvegardées.
class TapConfirmDiscardCommand extends FluentCommand {
  final WidgetTester tester;
  final SongListEditPageFinders finders;

  TapConfirmDiscardCommand(this.tester, this.finders);

  @override
  Future<void> execute() async {
    await tester.tap(finders.confirmDiscardButton);
    await tester.pumpAndSettle();
  }
}

/// Annule le dialogue de modifications non sauvegardées.
class TapCancelDiscardCommand extends FluentCommand {
  final WidgetTester tester;
  final SongListEditPageFinders finders;

  TapCancelDiscardCommand(this.tester, this.finders);

  @override
  Future<void> execute() async {
    await tester.tap(finders.cancelDiscardButton);
    await tester.pumpAndSettle();
  }
}

/// Vérifie le label du nombre d'entrées.
class ExpectEntriesCountLabelCommand extends FluentCommand {
  final int expectedCount;

  ExpectEntriesCountLabelCommand(this.expectedCount);

  @override
  Future<void> execute() async {
    expect(
      find.text('Chants ($expectedCount)'),
      findsOneWidget,
      reason: 'Entries count label should show $expectedCount',
    );
  }
}
