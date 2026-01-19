import 'package:flutter_test/flutter_test.dart';

import '../../types.dart';
import 'finders.dart';

/// Commande pour saisir une requête de recherche.
class EnterSearchQueryCommand extends FluentCommand {
  final WidgetTester tester;
  final HomePageFinders finders;
  final String query;

  EnterSearchQueryCommand(this.tester, this.finders, this.query);

  @override
  Future<void> execute() async {
    await tester.enterText(finders.searchField, query);
    await tester.pumpAndSettle();
  }
}

/// Commande pour effacer la recherche.
class ClearSearchCommand extends FluentCommand {
  final WidgetTester tester;
  final HomePageFinders finders;

  ClearSearchCommand(this.tester, this.finders);

  @override
  Future<void> execute() async {
    await tester.enterText(finders.searchField, '');
    await tester.pumpAndSettle();
  }
}

/// Commande pour taper sur une carte de chant.
class TapSongCardCommand extends FluentCommand {
  final WidgetTester tester;
  final HomePageFinders finders;
  final String songId;

  TapSongCardCommand(this.tester, this.finders, this.songId);

  @override
  Future<void> execute() async {
    await tester.tap(finders.songCardById(songId));
    await tester.pumpAndSettle();
  }
}

/// Commande pour taper sur le bouton paramètres.
class TapSettingsButtonCommand extends FluentCommand {
  final WidgetTester tester;
  final HomePageFinders finders;

  TapSettingsButtonCommand(this.tester, this.finders);

  @override
  Future<void> execute() async {
    await tester.tap(finders.settingsButton);
    await tester.pumpAndSettle();
  }
}

/// Commande pour vérifier que la grille de chants est visible.
class ExpectSongGridVisibleCommand extends FluentCommand {
  final HomePageFinders finders;

  ExpectSongGridVisibleCommand(this.finders);

  @override
  Future<void> execute() async {
    expect(
      finders.songGrid,
      findsOneWidget,
      reason: 'Song grid should be visible',
    );
  }
}

/// Commande pour vérifier que le chargement est affiché.
class ExpectLoadingVisibleCommand extends FluentCommand {
  final HomePageFinders finders;

  ExpectLoadingVisibleCommand(this.finders);

  @override
  Future<void> execute() async {
    expect(
      finders.loadingIndicator,
      findsOneWidget,
      reason: 'Loading indicator should be visible',
    );
  }
}

/// Commande pour vérifier que le message "aucun chant" est affiché.
class ExpectEmptyMessageVisibleCommand extends FluentCommand {
  final HomePageFinders finders;

  ExpectEmptyMessageVisibleCommand(this.finders);

  @override
  Future<void> execute() async {
    expect(
      finders.emptyMessage,
      findsOneWidget,
      reason: 'Empty message should be visible',
    );
  }
}

/// Commande pour vérifier le nombre de chants affichés.
class ExpectSongCountCommand extends FluentCommand {
  final HomePageFinders finders;
  final int expectedCount;

  ExpectSongCountCommand(this.finders, this.expectedCount);

  @override
  Future<void> execute() async {
    expect(
      finders.allSongCards,
      findsNWidgets(expectedCount),
      reason: 'Should display $expectedCount songs',
    );
  }
}

/// Commande pour vérifier qu'une carte de chant est visible.
class ExpectSongCardVisibleCommand extends FluentCommand {
  final HomePageFinders finders;
  final String songId;

  ExpectSongCardVisibleCommand(this.finders, this.songId);

  @override
  Future<void> execute() async {
    expect(
      finders.songCardById(songId),
      findsOneWidget,
      reason: 'Song card $songId should be visible',
    );
  }
}
