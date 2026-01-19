import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Localisateurs pour les éléments de la HomePage.
class HomePageFinders {
  final WidgetTester tester;

  HomePageFinders(this.tester);

  /// Champ de recherche.
  Finder get searchField => find.byKey(const Key('searchField'));

  /// Bouton paramètres dans l'AppBar.
  Finder get settingsButton => find.byKey(const Key('settingsButton'));

  /// Grille des chants.
  Finder get songGrid => find.byKey(const Key('songGridView'));

  /// Indicateur de chargement.
  Finder get loadingIndicator => find.byKey(const Key('loadingIndicator'));

  /// Message quand aucun chant n'est trouvé.
  Finder get emptyMessage => find.byKey(const Key('emptyMessage'));

  /// Message d'erreur.
  Finder get errorMessage => find.byKey(const Key('errorMessage'));

  /// Carte d'un chant par son ID.
  Finder songCardById(String id) => find.byKey(Key('songCard_$id'));

  /// Carte d'un chant par son code affiché.
  Finder songCardByCode(String code) => find.text(code);

  /// Toutes les cartes de chants visibles.
  Finder get allSongCards => find.byWidgetPredicate(
    (widget) => widget.key?.toString().contains('songCard_') ?? false,
  );
}
