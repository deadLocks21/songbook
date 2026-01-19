import '../../base.dart';
import '../home/actions.dart';
import 'commands.dart';
import 'finders.dart';

/// Actions fluentes pour la SongViewerPage.
class SongViewerPageActions extends FluentActionsBase {
  final SongViewerPageFinders _finders;

  SongViewerPageActions(super.navigation, super.tester)
    : _finders = SongViewerPageFinders(tester);

  // ==================== Assertions ====================

  /// Vérifie que le code du chant est celui attendu.
  SongViewerPageActions expectSongCodeIs(String code) {
    addCommand(ExpectSongCodeIsCommand(tester, _finders, code));
    return this;
  }

  /// Vérifie que le nom du chant est celui attendu.
  SongViewerPageActions expectSongNameIs(String name) {
    addCommand(ExpectSongNameIsCommand(tester, _finders, name));
    return this;
  }

  /// Vérifie que le visualiseur d'images est visible.
  SongViewerPageActions expectImageViewerVisible() {
    addCommand(ExpectImageViewerVisibleCommand(_finders));
    return this;
  }

  /// Vérifie que le message "aucune partition" est visible.
  SongViewerPageActions expectNoImageMessageVisible() {
    addCommand(ExpectNoImageMessageVisibleCommand(_finders));
    return this;
  }

  // ==================== Navigation ====================

  /// Retourne à la HomePage.
  HomePageActions goBack() {
    addCommand(TapBackButtonCommand(tester, _finders));
    return HomePageActions(navigation, tester)..commands.addAll(commands);
  }
}
