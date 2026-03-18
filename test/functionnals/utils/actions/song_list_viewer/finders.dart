import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Localisateurs pour les éléments de la SongListViewerPage.
class SongListViewerPageFinders {
  final WidgetTester tester;

  SongListViewerPageFinders(this.tester);

  /// Code du chant courant dans l'AppBar.
  Finder get songCode => find.byKey(const Key('viewerSongCode'));

  /// Nom du chant courant dans l'AppBar.
  Finder get songName => find.byKey(const Key('viewerSongName'));

  /// Indicateur de position (ex: "2/5").
  Finder get positionIndicator =>
      find.byKey(const Key('viewerPositionIndicator'));

  /// Bouton overview (liste des chants).
  Finder get overviewButton => find.byKey(const Key('viewerOverviewButton'));

  /// Bouton précédent.
  Finder get previousButton => find.byKey(const Key('viewerPreviousButton'));

  /// Bouton suivant.
  Finder get nextButton => find.byKey(const Key('viewerNextButton'));
}
