import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/application/dtos/resource.dto.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/infrastructure/song/providers/song.service_provider.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list.service_provider.dart';
import 'package:songbook/ui/pages/chord_pro_viewer/chord_pro_viewer.page.dart';
import 'package:songbook/ui/pages/chord_pro_viewer/providers/song_original_key.provider.dart';
import 'package:songbook/ui/pages/song_list_edit/widgets/song_list_entry_tile.widget.dart';
import 'package:songbook/ui/pages/song_list_edit/widgets/song_picker.widget.dart';
import 'package:songbook/ui/pages/song_viewer/song_viewer.page.dart';
import 'package:songbook/ui/utils/date_format.dart';

/// Page d'edition ou de creation d'une liste de chants.
class SongListEditPage extends ConsumerStatefulWidget {
  final SongListDto songList;

  const SongListEditPage({super.key, required this.songList});

  @override
  ConsumerState<SongListEditPage> createState() => _SongListEditPageState();
}

class _SongListEditPageState extends ConsumerState<SongListEditPage> {
  late DateTime _scheduledAt;
  late List<SongListEntryDto> _entries;
  bool _isSaving = false;

  /// Tonalité d'origine transmise au panneau de transposition réutilisable.
  /// Un seul notifier réutilisé entre ouvertures (mis à jour avant chaque tap).
  final ValueNotifier<String?> _transposeKey = ValueNotifier<String?>(null);

  bool get _isNew => widget.songList.entries.isEmpty;

  bool get _hasChanges {
    if (_scheduledAt != widget.songList.scheduledAt) return true;
    if (_entries.length != widget.songList.entries.length) return true;
    for (int i = 0; i < _entries.length; i++) {
      if (_entries[i].songId != widget.songList.entries[i].songId) return true;
      if (_entries[i].savedSemitones !=
          widget.songList.entries[i].savedSemitones) {
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _scheduledAt = widget.songList.scheduledAt;
    _entries = List.of(widget.songList.entries);
  }

  @override
  void dispose() {
    _transposeKey.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final songsById = {
      for (final song in ref.watch(songsProvider).value ?? []) song.id: song,
    };
    return PopScope(
      canPop: !_hasChanges || _isSaving,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || _isSaving) return;
        final shouldPop = await _showDiscardDialog();
        if (shouldPop == true && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isNew ? 'Nouvelle liste' : 'Modifier la liste',
            key: const Key('songListEditTitle'),
          ),
          leading: _isSaving ? const SizedBox.shrink() : null,
          actions: [
            IconButton(
              key: const Key('saveSongListButton'),
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              onPressed: _isSaving ? null : _save,
              tooltip: 'Enregistrer',
            ),
          ],
        ),
        floatingActionButton: _isSaving
            ? null
            : FloatingActionButton(
                key: const Key('addSongFab'),
                onPressed: _addSongs,
                tooltip: 'Ajouter un chant',
                child: const Icon(Icons.add),
              ),
        body: IgnorePointer(
          ignoring: _isSaving,
          child: AnimatedOpacity(
            opacity: _isSaving ? 0.5 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: InkWell(
                    key: const Key('dateTimePicker'),
                    onTap: _pickDateTime,
                    borderRadius: BorderRadius.circular(12.0),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date et heure',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        formatDate(_scheduledAt),
                        key: const Key('scheduledAtText'),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Chants (${_entries.length})',
                      key: const Key('entriesCountLabel'),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ),
                Expanded(
                  child: _entries.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucun chant dans la liste',
                            key: Key('songListEditEmpty'),
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ReorderableListView.builder(
                          key: const Key('songListEditReorderableList'),
                          buildDefaultDragHandles: false,
                          itemCount: _entries.length,
                          onReorder: _onReorder,
                          itemBuilder: (context, index) {
                            final entry = _entries[index];
                            final chordProUrl = songsById[entry.songId]
                                ?.resources
                                .whereType<ChordProResourceDto>()
                                .firstOrNull
                                ?.chordProUrl;
                            return SongListEntryTile(
                              key: ValueKey(entry.id),
                              entry: entry,
                              index: index,
                              totalCount: _entries.length,
                              onRemove: () => _removeEntry(index),
                              onTap: () => _viewSong(entry),
                              chordProUrl: chordProUrl,
                              onChangeKey: chordProUrl == null
                                  ? null
                                  : () => _changeKey(
                                      index,
                                      entry.songId,
                                      chordProUrl,
                                    ),
                              onMoveUp: index > 0
                                  ? () => _onReorder(index, index - 1)
                                  : null,
                              onMoveDown: index < _entries.length - 1
                                  ? () => _onReorder(index, index + 2)
                                  : null,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDiscardDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifications non sauvegardées'),
        content: const Text(
          'Vous avez des modifications non sauvegardées. Voulez-vous vraiment quitter ?',
        ),
        actions: [
          TextButton(
            key: const Key('cancelDiscardButton'),
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            key: const Key('confirmDiscardButton'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Quitter'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledAt,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
    );
    if (time == null || !mounted) return;

    setState(() {
      _scheduledAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _addSongs() async {
    await showSongPicker(
      context,
      onSongAdded: (song) {
        setState(() {
          _entries.add(
            SongListEntryDto(
              id: UuidValue.generate().value,
              songId: song.id,
              position: _entries.length,
              songCode: song.code,
              songName: song.name,
            ),
          );
        });
      },
    );
  }

  void _viewSong(SongListEntryDto entry) {
    final songs = ref.read(songsProvider).value;
    if (songs == null) return;
    final song = songs.where((s) => s.id == entry.songId).firstOrNull;
    if (song == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SongViewerPage(song: song)),
    );
  }

  /// Ouvre le panneau de transposition réutilisable pour modifier la tonalité
  /// enregistrée de l'entrée [index]. Le delta met à jour [_entries] (0 demi-ton
  /// => aucune tonalité enregistrée) ; la sauvegarde se fait via le bouton
  /// « Enregistrer » de la page.
  void _changeKey(int index, String songId, String chordProUrl) {
    _transposeKey.value = ref
        .read(songOriginalKeyProvider(songId, chordProUrl))
        .value;
    showChordProTransposeSheet(
      context,
      semitones: _entries[index].savedSemitones ?? 0,
      originalKey: _transposeKey,
      onTranspose: (delta) {
        setState(() {
          final current = _entries[index].savedSemitones ?? 0;
          final next = (current + delta).clamp(-11, 11);
          _entries[index] = _withSavedSemitones(
            _entries[index],
            next == 0 ? null : next,
          );
        });
      },
    );
  }

  /// Reconstruit l'entrée directement (copyWith ne sait pas remettre à null)
  /// pour pouvoir effacer la tonalité enregistrée.
  SongListEntryDto _withSavedSemitones(SongListEntryDto entry, int? semitones) {
    return SongListEntryDto(
      id: entry.id,
      songId: entry.songId,
      position: entry.position,
      savedSemitones: semitones,
      songCode: entry.songCode,
      songName: entry.songName,
    );
  }

  void _removeEntry(int index) {
    setState(() {
      _entries.removeAt(index);
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final entry = _entries.removeAt(oldIndex);
      _entries.insert(newIndex, entry);
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    try {
      final dto = SongListDto(
        id: widget.songList.id,
        scheduledAt: _scheduledAt,
        createdAt: widget.songList.createdAt,
        entries: _entries,
      );

      final service = ref.read(setlistServiceProvider);
      await service.save(dto);
      ref.invalidate(songListsProvider);
      await ref.read(songListsProvider.future);

      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
