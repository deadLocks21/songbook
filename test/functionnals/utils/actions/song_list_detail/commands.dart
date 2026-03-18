import 'package:flutter_test/flutter_test.dart';

import '../../types.dart';
import 'finders.dart';

/// Vérifie que le header est visible.
class ExpectHeaderVisibleCommand extends FluentCommand {
  final SongListDetailPageFinders finders;

  ExpectHeaderVisibleCommand(this.finders);

  @override
  Future<void> execute() async {
    expect(finders.header, findsOneWidget, reason: 'Header should be visible');
  }
}

/// Vérifie l'état vide.
class ExpectDetailEmptyCommand extends FluentCommand {
  final SongListDetailPageFinders finders;

  ExpectDetailEmptyCommand(this.finders);

  @override
  Future<void> execute() async {
    expect(
      finders.emptyState,
      findsOneWidget,
      reason: 'Empty state should be visible',
    );
  }
}

/// Vérifie le nombre d'entrées.
class ExpectEntryCountCommand extends FluentCommand {
  final SongListDetailPageFinders finders;
  final int expectedCount;

  ExpectEntryCountCommand(this.finders, this.expectedCount);

  @override
  Future<void> execute() async {
    for (int i = 0; i < expectedCount; i++) {
      expect(
        finders.entryByIndex(i),
        findsOneWidget,
        reason: 'Entry $i should be visible',
      );
    }
  }
}

/// Vérifie que le FAB Présenter est visible.
class ExpectPresentFabVisibleCommand extends FluentCommand {
  final SongListDetailPageFinders finders;

  ExpectPresentFabVisibleCommand(this.finders);

  @override
  Future<void> execute() async {
    expect(
      finders.presentFab,
      findsOneWidget,
      reason: 'Present FAB should be visible',
    );
  }
}

/// Vérifie que le FAB Présenter n'est pas visible.
class ExpectPresentFabNotVisibleCommand extends FluentCommand {
  final SongListDetailPageFinders finders;

  ExpectPresentFabNotVisibleCommand(this.finders);

  @override
  Future<void> execute() async {
    expect(
      finders.presentFab,
      findsNothing,
      reason: 'Present FAB should not be visible',
    );
  }
}

/// Tape sur le bouton modifier.
class TapEditButtonCommand extends FluentCommand {
  final WidgetTester tester;
  final SongListDetailPageFinders finders;

  TapEditButtonCommand(this.tester, this.finders);

  @override
  Future<void> execute() async {
    await tester.tap(finders.editButton);
    await tester.pumpAndSettle();
  }
}

/// Tape sur le bouton supprimer.
class TapDeleteButtonCommand extends FluentCommand {
  final WidgetTester tester;
  final SongListDetailPageFinders finders;

  TapDeleteButtonCommand(this.tester, this.finders);

  @override
  Future<void> execute() async {
    await tester.tap(finders.deleteButton);
    await tester.pumpAndSettle();
  }
}

/// Tape sur le FAB Présenter.
class TapPresentFabCommand extends FluentCommand {
  final WidgetTester tester;
  final SongListDetailPageFinders finders;

  TapPresentFabCommand(this.tester, this.finders);

  @override
  Future<void> execute() async {
    await tester.tap(finders.presentFab);
    await tester.pumpAndSettle();
  }
}

/// Confirme la suppression.
class TapDetailConfirmDeleteCommand extends FluentCommand {
  final WidgetTester tester;
  final SongListDetailPageFinders finders;

  TapDetailConfirmDeleteCommand(this.tester, this.finders);

  @override
  Future<void> execute() async {
    await tester.tap(finders.confirmDeleteButton);
    await tester.pumpAndSettle();
  }
}

/// Annule la suppression.
class TapDetailCancelDeleteCommand extends FluentCommand {
  final WidgetTester tester;
  final SongListDetailPageFinders finders;

  TapDetailCancelDeleteCommand(this.tester, this.finders);

  @override
  Future<void> execute() async {
    await tester.tap(finders.cancelDeleteButton);
    await tester.pumpAndSettle();
  }
}

/// Vérifie qu'un texte est visible.
class ExpectDetailTextVisibleCommand extends FluentCommand {
  final String text;

  ExpectDetailTextVisibleCommand(this.text);

  @override
  Future<void> execute() async {
    expect(
      find.text(text),
      findsWidgets,
      reason: 'Text "$text" should be visible',
    );
  }
}
