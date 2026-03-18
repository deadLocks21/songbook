import 'package:flutter_test/flutter_test.dart';

import '../../types.dart';
import 'finders.dart';

/// Vérifie le code du chant affiché.
class ExpectViewerSongCodeCommand extends FluentCommand {
  final String expectedCode;

  ExpectViewerSongCodeCommand(this.expectedCode);

  @override
  Future<void> execute() async {
    expect(
      find.text(expectedCode),
      findsWidgets,
      reason: 'Song code "$expectedCode" should be visible',
    );
  }
}

/// Vérifie le nom du chant affiché.
class ExpectViewerSongNameCommand extends FluentCommand {
  final String expectedName;

  ExpectViewerSongNameCommand(this.expectedName);

  @override
  Future<void> execute() async {
    expect(
      find.text(expectedName),
      findsWidgets,
      reason: 'Song name "$expectedName" should be visible',
    );
  }
}

/// Vérifie l'indicateur de position.
class ExpectPositionIndicatorCommand extends FluentCommand {
  final String expectedPosition;

  ExpectPositionIndicatorCommand(this.expectedPosition);

  @override
  Future<void> execute() async {
    expect(
      find.text(expectedPosition),
      findsOneWidget,
      reason: 'Position indicator should show "$expectedPosition"',
    );
  }
}

/// Vérifie que le bouton précédent est visible.
class ExpectPreviousButtonVisibleCommand extends FluentCommand {
  final SongListViewerPageFinders finders;

  ExpectPreviousButtonVisibleCommand(this.finders);

  @override
  Future<void> execute() async {
    expect(
      finders.previousButton,
      findsOneWidget,
      reason: 'Previous button should be visible',
    );
  }
}

/// Vérifie que le bouton précédent n'est pas visible.
class ExpectPreviousButtonNotVisibleCommand extends FluentCommand {
  final SongListViewerPageFinders finders;

  ExpectPreviousButtonNotVisibleCommand(this.finders);

  @override
  Future<void> execute() async {
    expect(
      finders.previousButton,
      findsNothing,
      reason: 'Previous button should not be visible',
    );
  }
}

/// Vérifie que le bouton suivant est visible.
class ExpectNextButtonVisibleCommand extends FluentCommand {
  final SongListViewerPageFinders finders;

  ExpectNextButtonVisibleCommand(this.finders);

  @override
  Future<void> execute() async {
    expect(
      finders.nextButton,
      findsOneWidget,
      reason: 'Next button should be visible',
    );
  }
}

/// Vérifie que le bouton suivant n'est pas visible.
class ExpectNextButtonNotVisibleCommand extends FluentCommand {
  final SongListViewerPageFinders finders;

  ExpectNextButtonNotVisibleCommand(this.finders);

  @override
  Future<void> execute() async {
    expect(
      finders.nextButton,
      findsNothing,
      reason: 'Next button should not be visible',
    );
  }
}

/// Tape sur le bouton suivant.
class TapNextButtonCommand extends FluentCommand {
  final WidgetTester tester;
  final SongListViewerPageFinders finders;

  TapNextButtonCommand(this.tester, this.finders);

  @override
  Future<void> execute() async {
    await tester.tap(finders.nextButton);
    await tester.pumpAndSettle();
  }
}

/// Tape sur le bouton précédent.
class TapPreviousButtonCommand extends FluentCommand {
  final WidgetTester tester;
  final SongListViewerPageFinders finders;

  TapPreviousButtonCommand(this.tester, this.finders);

  @override
  Future<void> execute() async {
    await tester.tap(finders.previousButton);
    await tester.pumpAndSettle();
  }
}

/// Tape sur le bouton overview.
class TapOverviewButtonCommand extends FluentCommand {
  final WidgetTester tester;
  final SongListViewerPageFinders finders;

  TapOverviewButtonCommand(this.tester, this.finders);

  @override
  Future<void> execute() async {
    await tester.tap(finders.overviewButton);
    await tester.pumpAndSettle();
  }
}

/// Tape sur un chant dans le overview sheet par son nom.
class TapOverviewEntryCommand extends FluentCommand {
  final WidgetTester tester;
  final String songName;

  TapOverviewEntryCommand(this.tester, this.songName);

  @override
  Future<void> execute() async {
    await tester.tap(find.text(songName).last);
    await tester.pumpAndSettle();
  }
}
