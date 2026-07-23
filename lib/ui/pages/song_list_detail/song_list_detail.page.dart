import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/application/dtos/resource.dto.dart';
import 'package:songbook/core/application/dtos/song.dto.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/infrastructure/song/providers/song.service_provider.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list.service_provider.dart';
import 'package:songbook/ui/pages/song_list_edit/song_list_edit.page.dart';
import 'package:songbook/ui/pages/song_lists/pull_song_list.action.dart';
import 'package:songbook/ui/pages/song_lists/share_song_list.action.dart';
import 'package:songbook/ui/pages/song_list_viewer/song_list_viewer.page.dart';
import 'package:songbook/ui/utils/date_format.dart';
import 'package:songbook/ui/widgets/song_key_badge.widget.dart';

/// Page de detail en lecture seule d'une liste de chants.
/// Permet de naviguer vers l'edition ou le visionnage.
class SongListDetailPage extends ConsumerStatefulWidget {
  final String songListId;

  const SongListDetailPage({super.key, required this.songListId});

  @override
  ConsumerState<SongListDetailPage> createState() => _SongListDetailPageState();
}

class _SongListDetailPageState extends ConsumerState<SongListDetailPage> {
  /// La vérification amont n'a lieu qu'une fois par ouverture. La page se
  /// reconstruit à chaque invalidation des listes — dont celle que la
  /// vérification déclenche elle-même : sans ce garde-fou, elle se rappellerait
  /// en boucle.
  bool _upstreamChecked = false;

  String get songListId => widget.songListId;

  @override
  Widget build(BuildContext context) {
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
        _checkUpstreamOnce(songList);
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

  /// Va voir où en est la source dès qu'on ouvre une liste suivie.
  ///
  /// C'est ici que la vérification a du sens : l'utilisateur regarde cette
  /// liste, c'est le moment où savoir qu'elle a bougé lui sert à quelque
  /// chose. Le faire à la synchro générale n'apprendrait rien de plus et
  /// interrogerait chaque source à chaque passage.
  ///
  /// Silencieux quand il n'y a rien : personne n'a rien demandé.
  void _checkUpstreamOnce(SongListDto songList) {
    if (_upstreamChecked || !songList.isFollowing) return;
    _upstreamChecked = true;

    // Après la frame : on est en plein build, et le tirage ouvre une feuille
    // modale et invalide des providers.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(pullSongList(context, ref, songList));
    });
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    SongListDto songList,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final List<SongDto> songs = ref.watch(songsProvider).value ?? const [];
    final songsById = {for (final song in songs) song.id: song};

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            key: const Key('editSongListButton'),
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _editList(context, ref, songList),
            tooltip: 'Modifier',
          ),
          // Une liste suivie ne se repartage pas : elle appartient à quelqu'un
          // d'autre, et la transmettre depuis ici sèmerait la confusion sur
          // qui en est l'auteur.
          if (!songList.isFollowing)
            IconButton(
              key: const Key('shareSongListButton'),
              icon: const Icon(Icons.ios_share),
              onPressed: () => shareSongList(context, ref, songList),
              tooltip: 'Partager',
            ),
          IconButton(
            key: const Key('deleteSongListButton'),
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref, songList),
            tooltip: 'Supprimer',
          ),
        ],
      ),
      floatingActionButton: songList.entries.isNotEmpty
          ? FloatingActionButton.extended(
              key: const Key('presentSongListFab'),
              onPressed: () => _viewList(context, songList),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Présenter'),
            )
          : null,
      body: songList.entries.isEmpty
          ? _buildEmptyState(context, colorScheme)
          : ListView.builder(
              key: const Key('songListDetailListView'),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
              itemCount: songList.entries.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildHeader(context, songList);
                }
                final entry = songList.entries[index - 1];
                final chordProUrl = songsById[entry.songId]?.resources
                    .whereType<ChordProResourceDto>()
                    .firstOrNull
                    ?.chordProUrl;
                return _buildSongTile(
                  context,
                  songList,
                  entry,
                  index - 1,
                  chordProUrl,
                );
              },
            ),
    );
  }

  Widget _buildHeader(BuildContext context, SongListDto songList) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final entryCount = songList.entries.length;

    return Padding(
      key: const Key('songListDetailHeader'),
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatDate(songList.scheduledAt),
            key: const Key('songListDetailDate'),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$entryCount chant${entryCount > 1 ? 's' : ''}',
            key: const Key('songListDetailCount'),
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
      key: const Key('songListDetailEmpty'),
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
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongTile(
    BuildContext context,
    SongListDto songList,
    SongListEntryDto entry,
    int index,
    String? chordProUrl,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      key: Key('songListDetailEntry_$index'),
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () => _viewList(context, songList, initialEntryId: entry.id),
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
              if (chordProUrl != null)
                SongKeyBadge(
                  songId: entry.songId,
                  chordProUrl: chordProUrl,
                  savedSemitones: entry.savedSemitones,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewList(
    BuildContext context,
    SongListDto songList, {
    String? initialEntryId,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SongListViewerPage(
          songListId: songList.id,
          initialEntryId: initialEntryId,
        ),
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
