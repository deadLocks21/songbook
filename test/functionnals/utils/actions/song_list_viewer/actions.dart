import '../../base.dart';
import 'commands.dart';
import 'finders.dart';

/// Actions fluentes pour la SongListViewerPage.
class SongListViewerPageActions extends FluentActionsBase {
  final SongListViewerPageFinders _finders;

  SongListViewerPageActions(super.navigation, super.tester)
    : _finders = SongListViewerPageFinders(tester);

  // ==================== Actions ====================

  /// Tape sur le bouton suivant.
  SongListViewerPageActions tapNextButton() {
    addCommand(TapNextButtonCommand(tester, _finders));
    return this;
  }

  /// Tape sur le bouton précédent.
  SongListViewerPageActions tapPreviousButton() {
    addCommand(TapPreviousButtonCommand(tester, _finders));
    return this;
  }

  /// Tape sur le bouton overview.
  SongListViewerPageActions tapOverviewButton() {
    addCommand(TapOverviewButtonCommand(tester, _finders));
    return this;
  }

  /// Tape sur un chant dans le overview sheet.
  SongListViewerPageActions tapOverviewEntry(String songName) {
    addCommand(TapOverviewEntryCommand(tester, songName));
    return this;
  }

  // ==================== Assertions ====================

  /// Vérifie le code du chant courant.
  SongListViewerPageActions expectSongCodeIs(String code) {
    addCommand(ExpectViewerSongCodeCommand(code));
    return this;
  }

  /// Vérifie le nom du chant courant.
  SongListViewerPageActions expectSongNameIs(String name) {
    addCommand(ExpectViewerSongNameCommand(name));
    return this;
  }

  /// Vérifie l'indicateur de position.
  SongListViewerPageActions expectPositionIs(String position) {
    addCommand(ExpectPositionIndicatorCommand(position));
    return this;
  }

  /// Vérifie que le bouton précédent est visible.
  SongListViewerPageActions expectPreviousButtonVisible() {
    addCommand(ExpectPreviousButtonVisibleCommand(_finders));
    return this;
  }

  /// Vérifie que le bouton précédent n'est pas visible.
  SongListViewerPageActions expectPreviousButtonNotVisible() {
    addCommand(ExpectPreviousButtonNotVisibleCommand(_finders));
    return this;
  }

  /// Vérifie que le bouton suivant est visible.
  SongListViewerPageActions expectNextButtonVisible() {
    addCommand(ExpectNextButtonVisibleCommand(_finders));
    return this;
  }

  /// Vérifie que le bouton suivant n'est pas visible.
  SongListViewerPageActions expectNextButtonNotVisible() {
    addCommand(ExpectNextButtonNotVisibleCommand(_finders));
    return this;
  }
}
