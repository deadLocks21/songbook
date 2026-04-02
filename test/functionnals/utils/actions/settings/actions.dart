import 'package:songbook/core/domain/model/theme_mode.dart';

import '../../base.dart';
import 'commands.dart';
import 'finders.dart';

/// Actions fluentes pour la SettingsPage.
class SettingsPageActions extends FluentActionsBase {
  final SettingsPageFinders _finders;

  SettingsPageActions(super.navigation, super.tester)
    : _finders = SettingsPageFinders(tester);

  // ==================== Actions Thème ====================

  /// Sélectionne le thème clair.
  SettingsPageActions tapThemeLight() {
    addCommand(TapThemeSegmentCommand(tester, 'Clair'));
    return this;
  }

  /// Sélectionne le thème sombre.
  SettingsPageActions tapThemeDark() {
    addCommand(TapThemeSegmentCommand(tester, 'Sombre'));
    return this;
  }

  /// Sélectionne le thème auto.
  SettingsPageActions tapThemeAuto() {
    addCommand(TapThemeSegmentCommand(tester, 'Auto'));
    return this;
  }

  // ==================== Actions URL Backend ====================

  /// Tape sur le bouton "Modifier" de l'URL.
  SettingsPageActions tapBackendUrlEdit() {
    addCommand(TapBackendUrlEditCommand(tester, _finders));
    return this;
  }

  /// Tape sur le bouton "Annuler" de l'URL.
  SettingsPageActions tapBackendUrlCancel() {
    addCommand(TapBackendUrlCancelCommand(tester, _finders));
    return this;
  }

  /// Saisit une URL dans le champ backend.
  SettingsPageActions enterBackendUrl(String url) {
    addCommand(EnterBackendUrlCommand(tester, _finders, url));
    return this;
  }

  /// Tape sur le bouton "Sauvegarder" de l'URL.
  SettingsPageActions tapBackendUrlSave() {
    addCommand(TapBackendUrlSaveCommand(tester, _finders));
    return this;
  }

  // ==================== Actions Base de données ====================

  /// Tape sur le bouton "Vider la base de données".
  SettingsPageActions tapClearDatabase() {
    addCommand(TapClearDatabaseCommand(tester, _finders));
    return this;
  }

  /// Confirme le vidage dans le dialog.
  SettingsPageActions tapConfirmClearDatabase() {
    addCommand(TapConfirmClearDatabaseCommand(tester, _finders));
    return this;
  }

  /// Annule le vidage dans le dialog.
  SettingsPageActions tapCancelClearDatabase() {
    addCommand(TapCancelClearDatabaseCommand(tester, _finders));
    return this;
  }

  // ==================== Assertions Thème ====================

  /// Vérifie que le thème sélectionné est le bon.
  SettingsPageActions expectThemeSelected(AppThemeMode mode) {
    addCommand(ExpectThemeSelectedCommand(_finders, mode));
    return this;
  }

  // ==================== Assertions URL Backend ====================

  /// Vérifie l'URL affichée.
  SettingsPageActions expectBackendUrl(String url) {
    addCommand(ExpectBackendUrlCommand(_finders, url));
    return this;
  }

  /// Vérifie que le champ URL est en lecture seule.
  SettingsPageActions expectBackendUrlReadonly() {
    addCommand(ExpectBackendUrlReadonlyCommand(_finders));
    return this;
  }

  /// Vérifie que le champ URL est éditable.
  SettingsPageActions expectBackendUrlEditable() {
    addCommand(ExpectBackendUrlEditableCommand(_finders));
    return this;
  }

  /// Vérifie que le bouton Sauvegarder est activé.
  SettingsPageActions expectSaveButtonEnabled() {
    addCommand(ExpectSaveButtonEnabledCommand(_finders));
    return this;
  }

  /// Vérifie que le bouton Sauvegarder est désactivé.
  SettingsPageActions expectSaveButtonDisabled() {
    addCommand(ExpectSaveButtonDisabledCommand(_finders));
    return this;
  }

  /// Vérifie que le bouton "Modifier" de l'URL est visible.
  SettingsPageActions expectBackendUrlEditButtonVisible() {
    addCommand(ExpectBackendUrlEditButtonVisibleCommand(_finders));
    return this;
  }

  /// Vérifie que le bouton "Modifier" de l'URL est absent.
  SettingsPageActions expectBackendUrlEditButtonAbsent() {
    addCommand(ExpectBackendUrlEditButtonAbsentCommand(_finders));
    return this;
  }

  // ==================== Assertions Dossier Sync ====================

  /// Vérifie le chemin affiché du dossier de synchronisation.
  SettingsPageActions expectSyncDirectoryPath(String path) {
    addCommand(ExpectSyncDirectoryPathCommand(_finders, path));
    return this;
  }

  /// Vérifie que le bouton "Réinitialiser" est absent.
  SettingsPageActions expectSyncDirectoryResetButtonAbsent() {
    addCommand(ExpectSyncDirectoryResetButtonAbsentCommand(_finders));
    return this;
  }

  /// Vérifie que le bouton "Réinitialiser" est visible.
  SettingsPageActions expectSyncDirectoryResetButtonVisible() {
    addCommand(ExpectSyncDirectoryResetButtonVisibleCommand(_finders));
    return this;
  }

  // ==================== Assertions Base de données ====================

  /// Vérifie que le dialog de confirmation est affiché.
  SettingsPageActions expectClearDatabaseDialogVisible() {
    addCommand(ExpectClearDatabaseDialogVisibleCommand());
    return this;
  }

  /// Vérifie que le dialog de confirmation est fermé.
  SettingsPageActions expectClearDatabaseDialogDismissed() {
    addCommand(ExpectClearDatabaseDialogDismissedCommand());
    return this;
  }
}
