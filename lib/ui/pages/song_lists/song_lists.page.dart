import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list.service_provider.dart';
import 'package:songbook/ui/pages/song_list_detail/song_list_detail.page.dart';
import 'package:songbook/ui/pages/song_list_edit/song_list_edit.page.dart';
import 'package:songbook/ui/pages/song_list_viewer/song_list_viewer.page.dart';
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
        data: (songLists) => _buildList(context, ref, songLists),
        loading: () => const Center(
          child: CircularProgressIndicator(key: Key('songListsLoading')),
        ),
        error: (error, stack) =>
            Center(child: Text('Erreur lors du chargement des listes: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('createSongListFab'),
        onPressed: () => _createNewList(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<SongListDto> songLists,
  ) {
    if (songLists.isEmpty) {
      return const Center(
        child: Text(
          'Aucune liste de chants',
          key: Key('songListsEmpty'),
          style: TextStyle(fontSize: 18.0, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      key: const Key('songListsListView'),
      padding: const EdgeInsets.all(16.0),
      itemCount: songLists.length,
      itemBuilder: (context, index) {
        final songList = songLists[index];
        return SongListCard(
          key: Key('songListCard_${songList.id}'),
          songList: songList,
          onTap: () => _showDetail(context, ref, songList),
          onView: () => _viewList(context, songList),
          onEdit: () => _editList(context, ref, songList),
          onDelete: () => _confirmDelete(context, ref, songList),
        );
      },
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
