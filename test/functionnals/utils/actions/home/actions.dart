import '../../base.dart';
import '../song_viewer/actions.dart';
import 'commands.dart';
import 'finders.dart';

/// Actions fluentes pour la HomePage.
class HomePageActions extends FluentActionsBase {
  final HomePageFinders _finders;

  HomePageActions(super.navigation, super.tester)
    : _finders = HomePageFinders(tester);

  // ==================== Actions ====================

  /// Saisit une requête de recherche.
  HomePageActions enterSearchQuery(String query) {
    addCommand(EnterSearchQueryCommand(tester, _finders, query));
    return this;
  }

  /// Efface la recherche.
  HomePageActions clearSearch() {
    addCommand(ClearSearchCommand(tester, _finders));
    return this;
  }

  /// Tape sur une carte de chant par son ID.
  HomePageActions tapSongCard(String songId) {
    addCommand(TapSongCardCommand(tester, _finders, songId));
    return this;
  }

  /// Tape sur le bouton paramètres.
  HomePageActions tapSettingsButton() {
    addCommand(TapSettingsButtonCommand(tester, _finders));
    return this;
  }

  // ==================== Assertions ====================

  /// Vérifie que la grille de chants est visible.
  HomePageActions expectSongGridVisible() {
    addCommand(ExpectSongGridVisibleCommand(_finders));
    return this;
  }

  /// Vérifie que le chargement est affiché.
  HomePageActions expectLoadingVisible() {
    addCommand(ExpectLoadingVisibleCommand(_finders));
    return this;
  }

  /// Vérifie que le message "aucun chant" est affiché.
  HomePageActions expectEmptyMessageVisible() {
    addCommand(ExpectEmptyMessageVisibleCommand(_finders));
    return this;
  }

  /// Vérifie le nombre de chants affichés.
  HomePageActions expectSongCount(int count) {
    addCommand(ExpectSongCountCommand(_finders, count));
    return this;
  }

  /// Vérifie qu'une carte de chant est visible.
  HomePageActions expectSongCardVisible(String songId) {
    addCommand(ExpectSongCardVisibleCommand(_finders, songId));
    return this;
  }

  // ==================== Navigation ====================

  /// Navigue vers la page de visualisation d'un chant.
  /// Note: Appeler tapSongCard() avant pour déclencher la navigation.
  SongViewerPageActions goToSongViewer() {
    return SongViewerPageActions(navigation, tester)..commands.addAll(commands);
  }
}
