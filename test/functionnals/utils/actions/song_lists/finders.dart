import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/ui/pages/song_lists/widgets/song_list_card.widget.dart';

/// Localisateurs pour les éléments de la SongListsPage.
class SongListsPageFinders {
  final WidgetTester tester;

  SongListsPageFinders(this.tester);

  /// ListView des listes.
  Finder get listView => find.byKey(const Key('songListsListView'));

  /// Indicateur de chargement.
  Finder get loadingIndicator => find.byKey(const Key('songListsLoading'));

  /// Message quand aucune liste n'est trouvée.
  Finder get emptyMessage => find.byKey(const Key('songListsEmpty'));

  /// FAB de création de liste.
  Finder get createFab => find.byKey(const Key('createSongListFab'));

  /// FAB pour suivre la liste de quelqu'un d'autre.
  Finder get followFab => find.byKey(const Key('followSongListFab'));

  /// Champ de saisie du code de partage.
  Finder get followCodeField => find.byKey(const Key('followCodeField'));

  /// Bouton confirmant la saisie du code.
  Finder get confirmFollowButton =>
      find.byKey(const Key('confirmFollowButton'));

  /// Badge signalant une liste reprise de quelqu'un d'autre.
  Finder get followedBadge => find.byKey(const Key('songListFollowedBadge'));

  /// Carte d'une liste par son ID.
  Finder songListCardById(String id) => find.byKey(Key('songListCard_$id'));

  /// Toutes les cartes de listes visibles.
  Finder get allSongListCards => find.byType(SongListCard);

  /// Bouton annuler dans le dialogue de suppression.
  Finder get cancelDeleteButton => find.byKey(const Key('cancelDeleteButton'));

  /// Bouton confirmer dans le dialogue de suppression.
  Finder get confirmDeleteButton =>
      find.byKey(const Key('confirmDeleteButton'));

  /// Menu contextuel "Visionner".
  Finder get contextMenuView => find.text('Visionner');

  /// Menu contextuel "Éditer".
  Finder get contextMenuEdit => find.text('Éditer');

  /// Menu contextuel "Supprimer".
  Finder get contextMenuDelete => find.text('Supprimer');

  /// Menu contextuel "Partager".
  Finder get contextMenuShare => find.text('Partager');
}
