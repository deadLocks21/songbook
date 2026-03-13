import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list.service_provider.dart';
import 'package:songbook/ui/pages/song_list_edit/widgets/song_list_entry_tile.widget.dart';
import 'package:songbook/ui/pages/song_list_edit/widgets/song_picker.widget.dart';
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

  bool get _isNew => widget.songList.entries.isEmpty;

  bool get _hasChanges {
    if (_scheduledAt != widget.songList.scheduledAt) return true;
    if (_entries.length != widget.songList.entries.length) return true;
    for (int i = 0; i < _entries.length; i++) {
      if (_entries[i].songId != widget.songList.entries[i].songId) return true;
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
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showDiscardDialog();
        if (shouldPop == true && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isNew ? 'Nouvelle liste' : 'Modifier la liste'),
          actions: [
            IconButton(
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
        floatingActionButton: FloatingActionButton(
          onPressed: _addSongs,
          tooltip: 'Ajouter un chant',
          child: const Icon(Icons.add),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: InkWell(
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
                      child: Text(formatDate(_scheduledAt)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Chants (${_entries.length})',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Expanded(
                  child: _entries.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucun chant dans la liste',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ReorderableListView.builder(
                          buildDefaultDragHandles: false,
                          itemCount: _entries.length,
                          onReorder: _onReorder,
                          itemBuilder: (context, index) {
                            final entry = _entries[index];
                            return SongListEntryTile(
                              key: ValueKey(entry.id),
                              entry: entry,
                              index: index,
                              onRemove: () => _removeEntry(index),
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
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
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

      final service = ref.read(songListServiceProvider);
      await service.saveSongList.execute(dto);
      ref.invalidate(songListsProvider);

      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
