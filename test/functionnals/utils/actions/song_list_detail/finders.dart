import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Localisateurs pour les éléments de la SongListDetailPage.
class SongListDetailPageFinders {
  final WidgetTester tester;

  SongListDetailPageFinders(this.tester);

  /// Header de la liste.
  Finder get header => find.byKey(const Key('songListDetailHeader'));

  /// Date affichée dans le header.
  Finder get dateText => find.byKey(const Key('songListDetailDate'));

  /// Nombre de chants affiché.
  Finder get countText => find.byKey(const Key('songListDetailCount'));

  /// ListView des entrées.
  Finder get listView => find.byKey(const Key('songListDetailListView'));

  /// État vide.
  Finder get emptyState => find.byKey(const Key('songListDetailEmpty'));

  /// Bouton modifier dans l'AppBar.
  Finder get editButton => find.byKey(const Key('editSongListButton'));

  /// Bouton supprimer dans l'AppBar.
  Finder get deleteButton => find.byKey(const Key('deleteSongListButton'));

  /// FAB Présenter.
  Finder get presentFab => find.byKey(const Key('presentSongListFab'));

  /// Entrée par index.
  Finder entryByIndex(int index) =>
      find.byKey(Key('songListDetailEntry_$index'));

  /// Bouton annuler dans le dialogue de suppression.
  Finder get cancelDeleteButton => find.byKey(const Key('cancelDeleteButton'));

  /// Bouton confirmer dans le dialogue de suppression.
  Finder get confirmDeleteButton =>
      find.byKey(const Key('confirmDeleteButton'));
}
