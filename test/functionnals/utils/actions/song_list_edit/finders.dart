import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Localisateurs pour les éléments de la SongListEditPage.
class SongListEditPageFinders {
  final WidgetTester tester;

  SongListEditPageFinders(this.tester);

  /// Titre de la page.
  Finder get title => find.byKey(const Key('songListEditTitle'));

  /// Bouton sauvegarder.
  Finder get saveButton => find.byKey(const Key('saveSongListButton'));

  /// FAB ajouter un chant.
  Finder get addSongFab => find.byKey(const Key('addSongFab'));

  /// Sélecteur de date/heure.
  Finder get dateTimePicker => find.byKey(const Key('dateTimePicker'));

  /// Texte de la date planifiée.
  Finder get scheduledAtText => find.byKey(const Key('scheduledAtText'));

  /// Label du nombre d'entrées.
  Finder get entriesCountLabel => find.byKey(const Key('entriesCountLabel'));

  /// État vide de la liste d'édition.
  Finder get emptyState => find.byKey(const Key('songListEditEmpty'));

  /// Liste réordonnnable.
  Finder get reorderableList =>
      find.byKey(const Key('songListEditReorderableList'));

  /// Bouton annuler dans le dialogue de modifications non sauvegardées.
  Finder get cancelDiscardButton =>
      find.byKey(const Key('cancelDiscardButton'));

  /// Bouton quitter dans le dialogue de modifications non sauvegardées.
  Finder get confirmDiscardButton =>
      find.byKey(const Key('confirmDiscardButton'));

  /// Bouton supprimer une entrée (par icône close).
  Finder get removeButtons => find.byIcon(Icons.close);

  /// Bouton supprimer une entrée à un index donné.
  Finder removeButtonAt(int index) {
    return find.byIcon(Icons.close).at(index);
  }
}
