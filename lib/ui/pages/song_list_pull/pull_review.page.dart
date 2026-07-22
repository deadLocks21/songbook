import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/application/services/song_list_pull.service.dart';
import 'package:songbook/core/domain/model/upstream_change.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/infrastructure/song/providers/song.repository_provider.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list_pull.provider.dart';
import 'package:songbook/ui/utils/date_format.dart';

/// Revue de ce que l'auteur a changé, quand la copie a été modifiée de son
/// côté et qu'il faut arbitrer.
///
/// Deux partis pris d'affichage :
///
/// - **Ce qui défait un travail personnel est décoché par défaut** et signalé.
///   Le reste est coché : l'usage courant est de tout prendre, et l'exception
///   doit demander un geste, pas l'inverse.
/// - **Un diff approximatif est annoncé comme tel.** Sans instantané de base,
///   les modifications de l'utilisateur se présentent comme des changements de
///   l'auteur ; le taire ferait appliquer n'importe quoi en confiance.
class PullReviewPage extends ConsumerStatefulWidget {
  final PullPreview preview;

  const PullReviewPage({super.key, required this.preview});

  @override
  ConsumerState<PullReviewPage> createState() => _PullReviewPageState();
}

class _PullReviewPageState extends ConsumerState<PullReviewPage> {
  late final Set<String> _selected = {
    for (final change in widget.preview.diff.changes)
      if (!change.undoesMyWork) change.id,
  };

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(songListPullProvider);
    final changes = widget.preview.diff.changes;

    return Scaffold(
      appBar: AppBar(title: const Text('Mise à jour de la liste')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96.0),
        children: [
          if (widget.preview.diff.isApproximate) _approximateWarning(context),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Text(
              'Voici ce qui a changé chez la personne qui partage cette liste. '
              'Vous choisissez ce que vous reprenez.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          for (final change in changes) _changeTile(context, change),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton(
            key: const Key('applyPullButton'),
            onPressed: busy ? null : _apply,
            child: Text(
              _selected.isEmpty
                  ? 'Ne rien reprendre'
                  : 'Reprendre ${_selected.length} changement${_selected.length > 1 ? 's' : ''}',
            ),
          ),
        ),
      ),
    );
  }

  Widget _approximateWarning(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      key: const Key('approximateDiffWarning'),
      margin: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: colors.onTertiaryContainer),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              'Comparaison approchée : cette copie a été récupérée depuis un '
              'autre appareil, donc vos propres modifications peuvent '
              'apparaître ici comme des changements de l\'auteur. Vérifiez '
              'avant de reprendre.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colors.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _changeTile(BuildContext context, UpstreamChange change) {
    final songsAsync = ref.watch(songsByIdProvider);

    return songsAsync.when(
      data: (songs) => CheckboxListTile(
        key: Key('pullChange_${change.id}'),
        value: _selected.contains(change.id),
        onChanged: (checked) => setState(() {
          checked == true
              ? _selected.add(change.id)
              : _selected.remove(change.id);
        }),
        secondary: Icon(_iconFor(change)),
        title: Text(_titleFor(change, songs)),
        subtitle: change.undoesMyWork
            ? Text(
                _warningFor(change),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              )
            : null,
      ),
      loading: () => const ListTile(title: LinearProgressIndicator()),
      error: (_, _) => ListTile(title: Text(_titleFor(change, const {}))),
    );
  }

  IconData _iconFor(UpstreamChange change) => switch (change) {
    SongAddedUpstream() => Icons.add,
    SongRemovedUpstream() => Icons.remove,
    TranspositionChangedUpstream() => Icons.music_note,
    ScheduleChangedUpstream() => Icons.event,
    OrderChangedUpstream() => Icons.swap_vert,
  };

  String _titleFor(UpstreamChange change, Map<UuidValue, String> songs) {
    String named(UuidValue songId) => songs[songId] ?? 'Chant supprimé';

    return switch (change) {
      SongAddedUpstream(:final songId) => 'Ajouter ${named(songId)}',
      SongRemovedUpstream(:final songId) => 'Retirer ${named(songId)}',
      TranspositionChangedUpstream(:final songId, :final semitones) =>
        semitones == null
            ? '${named(songId)} : revenir à la tonalité d\'origine'
            : '${named(songId)} : tonalité ${semitones > 0 ? '+' : ''}$semitones',
      ScheduleChangedUpstream(:final scheduledAt) =>
        'Date : ${formatDate(scheduledAt)}',
      OrderChangedUpstream() => 'Adopter l\'ordre de la liste partagée',
    };
  }

  String _warningFor(UpstreamChange change) => switch (change) {
    SongRemovedUpstream() => 'Vous aviez transposé ce chant',
    TranspositionChangedUpstream() => 'Remplace la tonalité que vous aviez choisie',
    OrderChangedUpstream() => 'Remplace l\'ordre que vous aviez mis',
    _ => '',
  };

  Future<void> _apply() async {
    final result = await ref
        .read(songListPullProvider.notifier)
        .applyReviewed(widget.preview, _selected);

    if (!mounted) return;

    Navigator.pop(context, result);
  }
}

/// Nom affichable de chaque chant du catalogue, pour traduire les identifiants
/// que portent les changements.
final songsByIdProvider = FutureProvider.autoDispose<Map<UuidValue, String>>((
  ref,
) async {
  final songs = await ref.watch(songRepositoryProvider).getAllSongs();

  return {for (final song in songs) song.id: '${song.code} · ${song.name}'};
});
