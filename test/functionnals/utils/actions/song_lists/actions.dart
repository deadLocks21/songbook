import 'package:flutter_test/flutter_test.dart';

import '../../base.dart';
import '../song_list_detail/actions.dart';
import '../song_list_edit/actions.dart';
import 'commands.dart';
import 'finders.dart';

/// Actions fluentes pour la SongListsPage.
class SongListsPageActions extends FluentActionsBase {
  final SongListsPageFinders _finders;

  SongListsPageActions(super.navigation, super.tester)
    : _finders = SongListsPageFinders(tester);

  // ==================== Actions ====================

  /// Tape sur une carte de liste par son ID.
  SongListsPageActions tapSongListCard(String songListId) {
    addCommand(TapSongListCardCommand(tester, _finders, songListId));
    return this;
  }

  /// Tape sur le FAB de création.
  SongListsPageActions tapCreateFab() {
    addCommand(TapCreateFabCommand(tester, _finders));
    return this;
  }

  /// Ouvre la boîte « Suivre une liste ».
  SongListsPageActions tapFollowFab() {
    addCommand(TapFollowFabCommand(tester, _finders));
    return this;
  }

  /// Saisit un code de partage.
  SongListsPageActions enterFollowCode(String code) {
    addCommand(EnterFollowCodeCommand(tester, _finders, code));
    return this;
  }

  /// Valide la saisie du code.
  SongListsPageActions submitFollowCode() {
    addCommand(SubmitFollowCodeCommand(tester, _finders));
    return this;
  }

  /// Appui long sur une carte (menu contextuel).
  SongListsPageActions longPressSongListCard(String songListId) {
    addCommand(LongPressSongListCardCommand(tester, _finders, songListId));
    return this;
  }

  /// Tape sur "Visionner" dans le menu contextuel.
  SongListsPageActions tapContextMenuView() {
    addCommand(TapContextMenuItemCommand(tester, _finders.contextMenuView));
    return this;
  }

  /// Tape sur "Éditer" dans le menu contextuel.
  SongListsPageActions tapContextMenuEdit() {
    addCommand(TapContextMenuItemCommand(tester, _finders.contextMenuEdit));
    return this;
  }

  /// Tape sur "Supprimer" dans le menu contextuel.
  SongListsPageActions tapContextMenuDelete() {
    addCommand(TapContextMenuItemCommand(tester, _finders.contextMenuDelete));
    return this;
  }

  /// Confirme la suppression dans le dialogue.
  SongListsPageActions confirmDelete() {
    addCommand(TapConfirmDeleteCommand(tester, _finders));
    return this;
  }

  /// Annule la suppression dans le dialogue.
  SongListsPageActions cancelDelete() {
    addCommand(TapCancelDeleteCommand(tester, _finders));
    return this;
  }

  // ==================== Assertions ====================

  /// Vérifie que la liste est visible.
  SongListsPageActions expectListVisible() {
    addCommand(ExpectSongListsVisibleCommand(_finders));
    return this;
  }

  /// Vérifie que le message vide est affiché.
  SongListsPageActions expectEmptyMessageVisible() {
    addCommand(ExpectSongListsEmptyCommand(_finders));
    return this;
  }

  /// Vérifie le nombre de listes affichées.
  SongListsPageActions expectSongListCount(int count) {
    addCommand(ExpectSongListCountCommand(_finders, count));
    return this;
  }

  /// Vérifie qu'un texte est visible.
  SongListsPageActions expectTextVisible(String text) {
    addCommand(ExpectTextVisibleCommand(text));
    return this;
  }

  /// Vérifie le nombre de listes signalées comme suivies.
  SongListsPageActions expectFollowedBadgeCount(int count) {
    addCommand(
      ExpectFinderCommand(
        _finders.followedBadge,
        findsNWidgets(count),
        'Il devrait y avoir $count liste(s) signalée(s) comme suivie(s)',
      ),
    );
    return this;
  }

  /// Vérifie que la boîte de saisie du code est ouverte.
  SongListsPageActions expectFollowDialogVisible() {
    addCommand(
      ExpectFinderCommand(
        _finders.followCodeField,
        findsOneWidget,
        'La boîte « Suivre une liste » devrait être ouverte',
      ),
    );
    return this;
  }

  /// Vérifie que le menu contextuel propose le partage.
  SongListsPageActions expectShareActionVisible() {
    addCommand(
      ExpectFinderCommand(
        _finders.contextMenuShare,
        findsOneWidget,
        'Le menu contextuel devrait proposer « Partager »',
      ),
    );
    return this;
  }

  /// Vérifie que le menu contextuel ne propose pas le partage.
  SongListsPageActions expectShareActionAbsent() {
    addCommand(
      ExpectFinderCommand(
        _finders.contextMenuShare,
        findsNothing,
        'Une liste suivie ne devrait pas pouvoir être repartagée',
      ),
    );
    return this;
  }

  // ==================== Navigation ====================

  /// Navigue vers la page de détail.
  SongListDetailPageActions goToSongListDetail() {
    return SongListDetailPageActions(navigation, tester)
      ..commands.addAll(commands);
  }

  /// Navigue vers la page d'édition.
  SongListEditPageActions goToSongListEdit() {
    return SongListEditPageActions(navigation, tester)
      ..commands.addAll(commands);
  }
}
