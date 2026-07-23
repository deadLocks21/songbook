import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/application/dtos/resource.dto.dart';
import 'package:songbook/core/application/dtos/song.dto.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/core/application/services/song_list_pull.service.dart';
import 'package:songbook/infrastructure/song/providers/song.service_provider.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list.service_provider.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list_pull.provider.dart';
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

/// Où en est la vérification de la source, pour une liste suivie.
enum _UpstreamCheck {
  /// On attend la réponse. Le contenu est masqué : le montrer puis le voir
  /// changer serait plus déroutant que d'attendre.
  checking,

  /// Serveur injoignable. La copie locale est là, mais peut-être en retard —
  /// l'utilisateur décide de continuer avec.
  failed,

  /// Plus rien à attendre : le contenu s'affiche.
  done,
}

class _SongListDetailPageState extends ConsumerState<SongListDetailPage> {
  /// `null` tant que la liste n'est pas chargée, donc tant qu'on ignore si elle
  /// suit une source.
  ///
  /// Sert aussi de garde-fou : la page se reconstruit à chaque invalidation des
  /// listes — dont celle que la vérification déclenche elle-même — et sans lui
  /// elle se rappellerait en boucle.
  _UpstreamCheck? _check;

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
        _startUpstreamCheck(songList);
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
  void _startUpstreamCheck(SongListDto songList) {
    if (_check != null) return;

    if (!songList.isFollowing) {
      _check = _UpstreamCheck.done;
      return;
    }

    _check = _UpstreamCheck.checking;

    // Après la frame : on est en plein build, et la suite met à jour l'état de
    // l'écran puis ouvre éventuellement une feuille modale.
    WidgetsBinding.instance.addPostFrameCallback((_) => _runUpstreamCheck(songList));
  }

  Future<void> _runUpstreamCheck(SongListDto songList) async {
    if (!mounted) return;

    final result = await ref
        .read(songListPullProvider.notifier)
        .pull(songList.id);

    if (!mounted) return;
    setState(() {
      _check = result is PullFailed ? _UpstreamCheck.failed : _UpstreamCheck.done;
    });

    // Après le dévoilement, pour que l'arbitrage se pose sur la liste plutôt
    // que sur un écran de chargement.
    if (mounted) await presentPullResult(context, ref, songList, result);
  }

  /// Ce qu'on montre pendant la vérification de la source.
  ///
  /// Bloquant : afficher la liste puis la voir changer sous les yeux serait
  /// plus déroutant que d'attendre une seconde. La barre de titre reste, avec
  /// son bouton retour — on attend, on n'est pas enfermé.
  Widget _checkingState(BuildContext context) {
    return Center(
      key: const Key('upstreamCheckLoader'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16.0),
          Text(
            'Vérification de la liste partagée…',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Ce qu'on montre quand le serveur n'a pas répondu.
  ///
  /// La copie locale est là et reste parfaitement utilisable : elle peut juste
  /// être en retard sur la source. On le dit, et on laisse l'utilisateur
  /// décider de continuer avec — sans quoi une coupure réseau rendrait sa
  /// propre liste inaccessible.
  Widget _checkFailedState(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      key: const Key('upstreamCheckFailed'),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 56.0, color: colors.onSurfaceVariant),
            const SizedBox(height: 16.0),
            Text(
              'Impossible de vérifier la liste partagée',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            Text(
              'Votre copie est disponible, mais elle n\'est peut-être pas à jour.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24.0),
            FilledButton(
              key: const Key('showLocalVersionButton'),
              onPressed: () => setState(() => _check = _UpstreamCheck.done),
              child: const Text('Voir ma version locale'),
            ),
          ],
        ),
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
    final List<SongDto> songs = ref.watch(songsProvider).value ?? const [];
    final songsById = {for (final song in songs) song.id: song};

    // Tant que la vérification n'a pas rendu la main, l'écran ne propose rien
    // d'autre que d'attendre ou de revenir : offrir d'éditer une liste qui va
    // peut-être changer dans la seconde n'aurait pas de sens.
    final settled = _check == _UpstreamCheck.done;

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (settled) ...[
            IconButton(
              key: const Key('editSongListButton'),
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _editList(context, ref, songList),
              tooltip: 'Modifier',
            ),
            // Une liste suivie ne se repartage pas : elle appartient à
            // quelqu'un d'autre, et la transmettre depuis ici sèmerait la
            // confusion sur qui en est l'auteur.
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
        ],
      ),
      floatingActionButton: settled && songList.entries.isNotEmpty
          ? FloatingActionButton.extended(
              key: const Key('presentSongListFab'),
              onPressed: () => _viewList(context, songList),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Présenter'),
            )
          : null,
      body: switch (_check) {
        _UpstreamCheck.checking => _checkingState(context),
        _UpstreamCheck.failed => _checkFailedState(context),
        _ => _listBody(context, colorScheme, songList, songsById),
      },
    );
  }

  Widget _listBody(
    BuildContext context,
    ColorScheme colorScheme,
    SongListDto songList,
    Map<String, SongDto> songsById,
  ) {
    return songList.entries.isEmpty
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
