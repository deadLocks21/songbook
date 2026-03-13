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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
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
          ? FloatingActionButton.extended(
              onPressed: () => _viewList(context, songList),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Présenter'),
            )
          : null,
      body: songList.entries.isEmpty
          ? _buildEmptyState(context, colorScheme)
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
              itemCount: songList.entries.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildHeader(context, songList);
                }
                final entry = songList.entries[index - 1];
                return _buildSongTile(context, entry, index - 1);
              },
            ),
    );
  }

  Widget _buildHeader(BuildContext context, SongListDto songList) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final entryCount = songList.entries.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatDate(songList.scheduledAt),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$entryCount chant${entryCount > 1 ? 's' : ''}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: colorScheme.outlineVariant, height: 1),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.queue_music_rounded,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun chant dans cette liste',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Appuyez sur modifier pour ajouter des chants',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongTile(
    BuildContext context,
    SongListEntryDto entry,
    int index,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${index + 1}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    entry.songName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    entry.songCode,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
