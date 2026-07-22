import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/core/application/services/song_list_sharing.service.dart';
import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list.service_provider.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list_pull.provider.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list_sync.provider.dart';
import 'package:songbook/infrastructure/song_list/providers/upstream_states.provider.dart';
import 'package:songbook/ui/pages/song_list_detail/song_list_detail.page.dart';
import 'package:songbook/ui/pages/song_list_edit/song_list_edit.page.dart';
import 'package:songbook/ui/pages/song_list_viewer/song_list_viewer.page.dart';
import 'package:songbook/ui/pages/song_lists/pull_song_list.action.dart';
import 'package:songbook/ui/pages/song_lists/share_song_list.action.dart';
import 'package:songbook/ui/pages/song_lists/widgets/follow_song_list.dialog.dart';
import 'package:songbook/ui/pages/song_lists/widgets/song_list_card.widget.dart';
import 'package:songbook/ui/utils/date_format.dart';

/// Page affichant la liste de toutes les listes de chants.
class SongListsPage extends ConsumerWidget {
  const SongListsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songListsAsync = ref.watch(songListsProvider);

    return Scaffold(
      body: songListsAsync.when(
        data: (songLists) => RefreshIndicator(
          key: const Key('songListsRefresh'),
          onRefresh: () => _refresh(context, ref),
          child: _buildList(context, ref, songLists),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(key: Key('songListsLoading')),
        ),
        error: (error, stack) =>
            Center(child: Text('Erreur lors du chargement des listes: $error')),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            key: const Key('followSongListFab'),
            heroTag: 'followSongList',
            tooltip: 'Suivre une liste',
            onPressed: () => _followList(context, ref),
            child: const Icon(Icons.link),
          ),
          const SizedBox(height: 12.0),
          FloatingActionButton(
            key: const Key('createSongListFab'),
            heroTag: 'createSongList',
            onPressed: () => _createNewList(context, ref),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<SongListDto> songLists,
  ) {
    // Même vide, la vue doit rester tirable : c'est justement là qu'on veut
    // pouvoir aller chercher ses listes depuis un autre appareil.
    if (songLists.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120.0),
          Center(
            child: Text(
              'Aucune liste de chants',
              key: Key('songListsEmpty'),
              style: TextStyle(fontSize: 18.0, color: Colors.grey),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      key: const Key('songListsListView'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      itemCount: songLists.length,
      itemBuilder: (context, index) {
        final songList = songLists[index];
        return SongListCard(
          key: Key('songListCard_${songList.id}'),
          songList: songList,
          hasUpstreamUpdate: ref
              .read(upstreamStatesProvider.notifier)
              .hasUpdateFor(songList),
          onTap: () => _showDetail(context, ref, songList),
          onView: () => _viewList(context, songList),
          onEdit: () => _editList(context, ref, songList),
          onShare: () => shareSongList(context, ref, songList),
          onPull: () =>
              pullSongList(context, ref, songList, announceWhenIdle: true),
          onUnfollow: () => _unfollowList(context, ref, songList),
          onDelete: () => _confirmDelete(context, ref, songList),
        );
      },
    );
  }

  /// Synchro manuelle : pousse ce qui attend puis récupère l'état du serveur,
  /// pour retrouver ici les listes créées ou modifiées sur un autre appareil.
  ///
  /// Le rafraîchissement de l'affichage est déclenché par la synchro elle-même ;
  /// on ne signale que l'échec, un succès se voit dans la liste.
  Future<void> _refresh(BuildContext context, WidgetRef ref) async {
    final succeeded = await ref
        .read(songListSyncProvider.notifier)
        .sync();

    if (succeeded || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        key: Key('songListsSyncFailed'),
        content: Text(
          'Synchronisation impossible. Vos listes restent disponibles hors ligne.',
        ),
      ),
    );
  }

  void _createNewList(BuildContext context, WidgetRef ref) {
    final newList = SongListDto(
      id: UuidValue.generate().value,
      scheduledAt: SongList.nextSundayAt10(),
      createdAt: DateTime.now(),
      entries: [],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SongListEditPage(songList: newList),
      ),
    ).then((_) => ref.invalidate(songListsProvider));
  }

  void _showDetail(BuildContext context, WidgetRef ref, SongListDto songList) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SongListDetailPage(songListId: songList.id),
      ),
    ).then((_) => ref.invalidate(songListsProvider));
  }

  void _viewList(BuildContext context, SongListDto songList) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SongListViewerPage(songListId: songList.id),
      ),
    );
  }

  void _editList(BuildContext context, WidgetRef ref, SongListDto songList) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SongListEditPage(songList: songList),
      ),
    ).then((_) => ref.invalidate(songListsProvider));
  }

  Future<void> _unfollowList(
    BuildContext context,
    WidgetRef ref,
    SongListDto songList,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ne plus suivre'),
        content: const Text(
          'Vous gardez la liste, elle devient une liste comme les autres. '
          'Vous ne recevrez plus les changements de la personne qui l\'a partagée.',
        ),
        actions: [
          TextButton(
            key: const Key('cancelUnfollowButton'),
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            key: const Key('confirmUnfollowButton'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ne plus suivre'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await ref.read(songListPullProvider.notifier).unfollow(songList.id);
    if (!context.mounted) return;

    _notify(context, 'Vous ne suivez plus cette liste.');
    ref.invalidate(songListsProvider);
  }

  void _notify(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(key: const Key('songListPullMessage'), content: Text(message)),
    );
  }

  /// Demande un code, puis ouvre ce qu'il a donné.
  Future<void> _followList(BuildContext context, WidgetRef ref) async {
    final outcome = await showDialog<FollowOutcome>(
      context: context,
      builder: (context) => const FollowSongListDialog(),
    );

    if (outcome == null || !context.mounted) return;

    ref.invalidate(songListsProvider);

    final listId = outcome.listId;
    if (listId == null) {
      // Copie faite depuis un autre appareil : elle n'est pas encore ici, et
      // l'ouvrir mènerait à un écran vide.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          key: Key('songListAlreadyFollowedElsewhere'),
          content: Text(
            'Vous suivez déjà cette liste depuis un autre appareil. '
            'Synchronisez pour la récupérer ici.',
          ),
        ),
      );
      return;
    }

    final message = switch (outcome.status) {
      FollowStatus.copied => 'Liste copiée. Elle est à vous, modifiez-la comme vous voulez.',
      FollowStatus.alreadyOwner => 'Cette liste est déjà la vôtre.',
      FollowStatus.alreadyFollowing => 'Vous suivez déjà cette liste.',
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(key: const Key('songListFollowed'), content: Text(message)),
    );

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SongListDetailPage(songListId: listId.value),
      ),
    ).then((_) => ref.invalidate(songListsProvider));
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    SongListDto songList,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la liste'),
        content: Text(
          'Voulez-vous supprimer la liste du ${formatDate(songList.scheduledAt)} ?',
        ),
        actions: [
          TextButton(
            key: const Key('cancelDeleteButton'),
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            key: const Key('confirmDeleteButton'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final service = ref.read(setlistServiceProvider);
      await service.delete(songList.id);
      ref.invalidate(songListsProvider);
    }
  }
}
