import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Localisateurs pour les éléments de la SongViewerPage.
class SongViewerPageFinders {
  final WidgetTester tester;

  SongViewerPageFinders(this.tester);

  /// Code du chant dans l'AppBar.
  Finder get songCode => find.byKey(const Key('songCode'));

  /// Nom du chant dans l'AppBar.
  Finder get songName => find.byKey(const Key('songName'));

  /// Bouton retour.
  Finder get backButton => find.byType(BackButton);

  /// Visualiseur d'images.
  Finder get imageViewer => find.byKey(const Key('imageViewer'));

  /// Message quand aucune image n'est disponible.
  Finder get noImageMessage => find.byKey(const Key('noImageMessage'));
}
