import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list.service_provider.dart';
import 'package:songbook/ui/pages/song_list_edit/song_list_edit.page.dart';
import 'package:songbook/ui/pages/song_list_viewer/song_list_viewer.page.dart';
import 'package:songbook/ui/utils/date_format.dart';

/// Page de detail en lecture seule d'une liste de chants.
/// Permet de naviguer vers l'edition ou le visionnage.
class SongListDetailPage extends ConsumerWidget {
  final String songListId;

  const SongListDetailPage({super.key, required this.songListId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songListsAsync = ref.watch(songListsProvider);

    return songListsAsync.when(
      data: (songLists) {
        final songList = songLists.where((s) => s.id == songListId).firstOrNull;
        if (songList == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Liste introuvable')),
            body: const Center(child: Text('Cette liste n\'existe plus.')),
          );
        }
        return _buildContent(context, ref, songList);
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Erreur: $error')),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    SongListDto songList,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(formatDate(songList.scheduledAt)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editList(context, ref, songList),
            tooltip: 'Modifier',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref, songList),
            tooltip: 'Supprimer',
          ),
        ],
      ),
      floatingActionButton: songList.entries.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _viewList(context, songList),
              tooltip: 'Présenter',
              child: const Icon(Icons.play_arrow),
            )
          : null,
      body: songList.entries.isEmpty
          ? const Center(
              child: Text(
                'Aucun chant dans cette liste',
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: songList.entries.length,
              itemBuilder: (context, index) {
                final entry = songList.entries[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  title: Text(entry.songCode),
                  subtitle: Text(entry.songName),
                );
              },
            ),
    );
  }

  void _viewList(BuildContext context, SongListDto songList) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SongListViewerPage(songListId: songList.id),
      ),
    );
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
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final service = ref.read(songListServiceProvider);
      await service.deleteSongList.execute(songList.id);
      ref.invalidate(songListsProvider);
      if (context.mounted) Navigator.pop(context);
    }
  }

  void _editList(BuildContext context, WidgetRef ref, SongListDto songList) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SongListEditPage(songList: songList),
      ),
    ).then((_) => ref.invalidate(songListsProvider));
  }
}
