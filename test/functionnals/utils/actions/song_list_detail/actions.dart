import '../../base.dart';
import '../song_list_edit/actions.dart';
import 'commands.dart';
import 'finders.dart';

/// Actions fluentes pour la SongListDetailPage.
class SongListDetailPageActions extends FluentActionsBase {
  final SongListDetailPageFinders _finders;

  SongListDetailPageActions(super.navigation, super.tester)
    : _finders = SongListDetailPageFinders(tester);

  // ==================== Actions ====================

  /// Tape sur le bouton modifier.
  SongListDetailPageActions tapEditButton() {
    addCommand(TapEditButtonCommand(tester, _finders));
    return this;
  }

  /// Tape sur le bouton supprimer.
  SongListDetailPageActions tapDeleteButton() {
    addCommand(TapDeleteButtonCommand(tester, _finders));
    return this;
  }

  /// Tape sur le FAB Présenter.
  SongListDetailPageActions tapPresentFab() {
    addCommand(TapPresentFabCommand(tester, _finders));
    return this;
  }

  /// Confirme la suppression.
  SongListDetailPageActions confirmDelete() {
    addCommand(TapDetailConfirmDeleteCommand(tester, _finders));
    return this;
  }

  /// Annule la suppression.
  SongListDetailPageActions cancelDelete() {
    addCommand(TapDetailCancelDeleteCommand(tester, _finders));
    return this;
  }

  // ==================== Assertions ====================

  /// Vérifie que le header est visible.
  SongListDetailPageActions expectHeaderVisible() {
    addCommand(ExpectHeaderVisibleCommand(_finders));
    return this;
  }

  /// Vérifie l'état vide.
  SongListDetailPageActions expectEmptyStateVisible() {
    addCommand(ExpectDetailEmptyCommand(_finders));
    return this;
  }

  /// Vérifie le nombre d'entrées.
  SongListDetailPageActions expectEntryCount(int count) {
    addCommand(ExpectEntryCountCommand(_finders, count));
    return this;
  }

  /// Vérifie que le partage est offert depuis le détail.
  SongListDetailPageActions expectShareButtonVisible() {
    addCommand(ExpectShareButtonVisibleCommand(_finders));
    return this;
  }

  /// Vérifie que le FAB Présenter est visible.
  SongListDetailPageActions expectPresentFabVisible() {
    addCommand(ExpectPresentFabVisibleCommand(_finders));
    return this;
  }

  /// Vérifie que le FAB Présenter n'est pas visible.
  SongListDetailPageActions expectPresentFabNotVisible() {
    addCommand(ExpectPresentFabNotVisibleCommand(_finders));
    return this;
  }

  /// Vérifie qu'un texte est visible.
  SongListDetailPageActions expectTextVisible(String text) {
    addCommand(ExpectDetailTextVisibleCommand(text));
    return this;
  }

  // ==================== Navigation ====================

  /// Navigue vers la page d'édition.
  SongListEditPageActions goToSongListEdit() {
    return SongListEditPageActions(navigation, tester)
      ..commands.addAll(commands);
  }
}
