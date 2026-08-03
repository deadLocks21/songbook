import '../../base.dart';
import 'commands.dart';
import 'finders.dart';

/// Actions fluentes pour la SongListEditPage.
class SongListEditPageActions extends FluentActionsBase {
  final SongListEditPageFinders _finders;

  SongListEditPageActions(super.navigation, super.tester)
    : _finders = SongListEditPageFinders(tester);

  // ==================== Actions ====================

  /// Tape sur le bouton sauvegarder.
  SongListEditPageActions tapSaveButton() {
    addCommand(TapSaveButtonCommand(tester, _finders));
    return this;
  }

  /// Tape sur le FAB ajouter un chant.
  SongListEditPageActions tapAddSongFab() {
    addCommand(TapAddSongFabCommand(tester, _finders));
    return this;
  }

  /// Tape sur le sélecteur de date/heure.
  SongListEditPageActions tapDateTimePicker() {
    addCommand(TapDateTimePickerCommand(tester, _finders));
    return this;
  }

  /// Supprime l'entrée à l'index donné.
  SongListEditPageActions removeEntryAt(int index) {
    addCommand(TapRemoveEntryCommand(tester, _finders, index));
    return this;
  }

  /// Confirme le dialogue de modifications non sauvegardées.
  SongListEditPageActions confirmDiscard() {
    addCommand(TapConfirmDiscardCommand(tester, _finders));
    return this;
  }

  /// Annule le dialogue de modifications non sauvegardées.
  SongListEditPageActions cancelDiscard() {
    addCommand(TapCancelDiscardCommand(tester, _finders));
    return this;
  }

  // ==================== Assertions ====================

  /// Vérifie le titre de la page.
  SongListEditPageActions expectTitle(String title) {
    addCommand(ExpectEditTitleCommand(title));
    return this;
  }

  /// Vérifie l'état vide.
  SongListEditPageActions expectEmptyStateVisible() {
    addCommand(ExpectEditEmptyCommand(_finders));
    return this;
  }

  /// Vérifie que la liste réordonnable est visible.
  SongListEditPageActions expectReorderableListVisible() {
    addCommand(ExpectReorderableListVisibleCommand(_finders));
    return this;
  }

  /// Vérifie qu'un texte est visible.
  SongListEditPageActions expectTextVisible(String text) {
    addCommand(ExpectEditTextVisibleCommand(text));
    return this;
  }

  /// Vérifie qu'un texte contenant [text] est visible.
  SongListEditPageActions expectTextContaining(String text) {
    addCommand(ExpectEditTextContainingCommand(text));
    return this;
  }

  /// Vérifie qu'un texte n'est pas visible.
  SongListEditPageActions expectTextNotVisible(String text) {
    addCommand(ExpectEditTextNotVisibleCommand(text));
    return this;
  }

  /// Vérifie le label du nombre d'entrées.
  SongListEditPageActions expectEntriesCount(int count) {
    addCommand(ExpectEntriesCountLabelCommand(count));
    return this;
  }
}
