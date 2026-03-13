import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/application/dtos/song.dto.dart';
import 'package:songbook/infrastructure/song/providers/song.service_provider.dart';
import 'package:songbook/ui/pages/song_viewer/song_viewer.page.dart';

/// Affiche un bottom sheet permettant de choisir des chants a ajouter.
Future<void> showSongPicker(
  BuildContext context, {
  required void Function(SongDto song) onSongAdded,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _SongPickerSheet(onSongAdded: onSongAdded),
  );
}

class _SongPickerSheet extends ConsumerStatefulWidget {
  final void Function(SongDto song) onSongAdded;

  const _SongPickerSheet({required this.onSongAdded});

  @override
  ConsumerState<_SongPickerSheet> createState() => _SongPickerSheetState();
}

class _SongPickerSheetState extends ConsumerState<_SongPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final songsAsync = ref.watch(songsProvider);

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
                      title: Text(song.name),
                      subtitle: Text(song.code),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility_outlined),
                            tooltip: 'Prévisualiser',
                            onPressed: () async {
                              final added = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (viewerContext) => SongViewerPage(
                                    song: song,
                                    actions: [
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        tooltip: 'Ajouter',
                                        onPressed: () =>
                                            Navigator.pop(viewerContext, true),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                              if (added == true && context.mounted) {
                                widget.onSongAdded(song);
                                Navigator.pop(context);
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            tooltip: 'Ajouter',
                            onPressed: () {
                              widget.onSongAdded(song);
                              Navigator.pop(context);
                            },
                          ),
                        ],
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
}
