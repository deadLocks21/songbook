import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/application/dtos/song.dto.dart';
import 'package:songbook/core/domain/model/song_schedule.dart';
import 'package:songbook/infrastructure/song/providers/song.service_provider.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list.service_provider.dart';
import 'package:songbook/ui/pages/song_viewer/song_viewer.page.dart';
import 'package:songbook/ui/widgets/song_schedule_label.widget.dart';
import 'package:songbook/ui/widgets/song_title.widget.dart';

/// Affiche un bottom sheet permettant de choisir des chants a ajouter.
///
/// [excludingListId] est la liste en cours d'edition : elle ne doit pas se
/// compter dans l'historique affiche, sans quoi chacun de ses chants
/// s'annoncerait « deja prevu » en pointant cette liste-la.
Future<void> showSongPicker(
  BuildContext context, {
  required void Function(SongDto song) onSongAdded,
  String? excludingListId,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _SongPickerSheet(
      onSongAdded: onSongAdded,
      excludingListId: excludingListId,
    ),
  );
}

class _SongPickerSheet extends ConsumerStatefulWidget {
  final void Function(SongDto song) onSongAdded;
  final String? excludingListId;

  const _SongPickerSheet({required this.onSongAdded, this.excludingListId});

  @override
  ConsumerState<_SongPickerSheet> createState() => _SongPickerSheetState();
}

class _SongPickerSheetState extends ConsumerState<_SongPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final songsAsync = ref.watch(songsProvider);
    // L'historique se fait attendre le temps d'un chargement de listes : les
    // chants s'affichent sans, plutot que de retenir tout le selecteur.
    final schedules =
        ref
            .watch(
              songSchedulesProvider(excludingListId: widget.excludingListId),
            )
            .value ??
        const <String, SongSchedule>{};

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Rechercher un chant...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: songsAsync.when(
              data: (songs) {
                final filtered = _query.isEmpty
                    ? songs
                    : songs.where((s) {
                        final q = _query.toLowerCase();
                        return s.code.toLowerCase().contains(q) ||
                            s.name.toLowerCase().contains(q);
                      }).toList();

                return ListView.builder(
                  controller: scrollController,
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final song = filtered[index];
                    return ListTile(
                      // Le code passe devant le titre, en plus petit : il sert
                      // a reperer le chant, pas a le nommer. Il laisse ainsi
                      // toute la deuxieme ligne a l'historique, qui a besoin de
                      // sa largeur — « chante il y a 3 semaines · 3 fois en
                      // 3 mois » se faisait couper en partageant sa ligne.
                      title: SongTitle(code: song.code, name: song.name),
                      subtitle: SongScheduleLabel(
                        key: Key('songSchedule_${song.id}'),
                        schedule: schedules[song.id] ?? SongSchedule.never,
                      ),
                      onTap: () => _previewSong(song),
                      trailing: IconButton(
                        icon: const Icon(Icons.add),
                        tooltip: 'Ajouter',
                        onPressed: () {
                          widget.onSongAdded(song);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Erreur: $error')),
            ),
          ),
        ],
      ),
    );
  }

  void _previewSong(SongDto song) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SongViewerPage(
          song: song,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Ajouter à la liste',
              onPressed: () {
                widget.onSongAdded(song);
                // Ferme la preview puis le bottom sheet
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
