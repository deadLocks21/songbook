import 'package:flutter/material.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';

/// Tuile representant une entree dans la liste reordonnnable.
class SongListEntryTile extends StatelessWidget {
  final SongListEntryDto entry;
  final int index;
  final VoidCallback onRemove;

  const SongListEntryTile({
    super.key,
    required this.entry,
    required this.index,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ReorderableDragStartListener(
      index: index,
      child: ListTile(
        leading: const Icon(Icons.drag_handle),
        title: Text(
          '${entry.songCode} - ${entry.songName}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: onRemove,
        ),
      ),
    );
  }
}
