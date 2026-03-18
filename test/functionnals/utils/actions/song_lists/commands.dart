import 'package:flutter_test/flutter_test.dart';

import '../../types.dart';
import 'finders.dart';

/// Commande pour vérifier que la liste est visible.
class ExpectSongListsVisibleCommand extends FluentCommand {
  final SongListsPageFinders finders;

  ExpectSongListsVisibleCommand(this.finders);

  @override
  Future<void> execute() async {
    expect(
      finders.listView,
      findsOneWidget,
      reason: 'Song lists ListView should be visible',
    );
  }
}

/// Commande pour vérifier le message vide.
class ExpectSongListsEmptyCommand extends FluentCommand {
  final SongListsPageFinders finders;

  ExpectSongListsEmptyCommand(this.finders);

  @override
  Future<void> execute() async {
    expect(
      finders.emptyMessage,
      findsOneWidget,
      reason: 'Empty message should be visible',
    );
  }
}

/// Commande pour vérifier le nombre de listes.
class ExpectSongListCountCommand extends FluentCommand {
  final SongListsPageFinders finders;
  final int expectedCount;

  ExpectSongListCountCommand(this.finders, this.expectedCount);

  @override
  Future<void> execute() async {
    expect(
      finders.allSongListCards,
      findsNWidgets(expectedCount),
      reason: 'Should display $expectedCount song lists',
    );
  }
}

/// Commande pour taper sur une carte de liste.
class TapSongListCardCommand extends FluentCommand {
  final WidgetTester tester;
  final SongListsPageFinders finders;
  final String songListId;

  TapSongListCardCommand(this.tester, this.finders, this.songListId);

  @override
  Future<void> execute() async {
    await tester.tap(finders.songListCardById(songListId));
    await tester.pumpAndSettle();
  }
}

/// Commande pour taper sur le FAB de création.
class TapCreateFabCommand extends FluentCommand {
  final WidgetTester tester;
  final SongListsPageFinders finders;

  TapCreateFabCommand(this.tester, this.finders);

  @override
  Future<void> execute() async {
    await tester.tap(finders.createFab);
    await tester.pumpAndSettle();
  }
}

/// Commande pour appui long sur une carte (menu contextuel).
class LongPressSongListCardCommand extends FluentCommand {
  final WidgetTester tester;
  final SongListsPageFinders finders;
  final String songListId;

  LongPressSongListCardCommand(this.tester, this.finders, this.songListId);

  @override
  Future<void> execute() async {
    await tester.longPress(finders.songListCardById(songListId));
    await tester.pumpAndSettle();
  }
}

/// Commande pour taper sur un élément du menu contextuel.
class TapContextMenuItemCommand extends FluentCommand {
  final WidgetTester tester;
  final Finder menuItem;

  TapContextMenuItemCommand(this.tester, this.menuItem);

  @override
  Future<void> execute() async {
    await tester.tap(menuItem);
    await tester.pumpAndSettle();
  }
}

/// Commande pour confirmer la suppression.
class TapConfirmDeleteCommand extends FluentCommand {
  final WidgetTester tester;
  final SongListsPageFinders finders;

  TapConfirmDeleteCommand(this.tester, this.finders);

  @override
  Future<void> execute() async {
    await tester.tap(finders.confirmDeleteButton);
    await tester.pumpAndSettle();
  }
}

/// Commande pour annuler la suppression.
class TapCancelDeleteCommand extends FluentCommand {
  final WidgetTester tester;
  final SongListsPageFinders finders;

  TapCancelDeleteCommand(this.tester, this.finders);

  @override
  Future<void> execute() async {
    await tester.tap(finders.cancelDeleteButton);
    await tester.pumpAndSettle();
  }
}

/// Commande pour vérifier qu'un texte est visible.
class ExpectTextVisibleCommand extends FluentCommand {
  final String text;

  ExpectTextVisibleCommand(this.text);

  @override
  Future<void> execute() async {
    expect(
      find.text(text),
      findsWidgets,
      reason: 'Text "$text" should be visible',
    );
  }
}
