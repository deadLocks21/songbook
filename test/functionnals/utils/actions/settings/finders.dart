import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Localisateurs pour les éléments de la SettingsPage.
class SettingsPageFinders {
  final WidgetTester tester;

  SettingsPageFinders(this.tester);

  /// Sélecteur de thème (SegmentedButton).
  Finder get themeSegmentedButton =>
      find.byKey(const Key('themeSegmentedButton'));

  /// Champ de saisie de l'URL du backend.
  Finder get backendUrlField => find.byKey(const Key('backendUrlField'));

  /// Bouton "Modifier" de l'URL du backend.
  Finder get backendUrlEditButton =>
      find.byKey(const Key('backendUrlEditButton'));

  /// Bouton "Annuler" de l'URL du backend.
  Finder get backendUrlCancelButton =>
      find.byKey(const Key('backendUrlCancelButton'));

  /// Bouton "Sauvegarder" de l'URL du backend.
  Finder get backendUrlSaveButton =>
      find.byKey(const Key('backendUrlSaveButton'));

  /// Bouton de synchronisation de l'URL du backend.
  Finder get backendUrlSyncButton =>
      find.byKey(const Key('backendUrlSyncButton'));

  /// Container affichant le chemin du dossier de synchronisation.
  Finder get syncDirectoryPath => find.byKey(const Key('syncDirectoryPath'));

  /// Bouton "Modifier" du dossier de synchronisation.
  Finder get syncDirectoryModifyButton =>
      find.byKey(const Key('syncDirectoryModifyButton'));

  /// Bouton "Réinitialiser" du dossier de synchronisation.
  Finder get syncDirectoryResetButton =>
      find.byKey(const Key('syncDirectoryResetButton'));

  /// Bouton "Vider la base de données".
  Finder get clearDatabaseButton =>
      find.byKey(const Key('clearDatabaseButton'));

  /// Bouton "Supprimer" dans le dialog de confirmation.
  Finder get clearDatabaseConfirmButton =>
      find.byKey(const Key('clearDatabaseConfirmButton'));

  /// Bouton "Annuler" dans le dialog de confirmation.
  Finder get clearDatabaseCancelButton =>
      find.byKey(const Key('clearDatabaseCancelButton'));
}
