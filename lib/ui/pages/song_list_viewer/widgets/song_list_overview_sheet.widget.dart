import 'package:flutter/material.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';

/// Affiche un bottom sheet avec la liste complete des chants
/// pour navigation rapide dans le mode visualisation.
Future<int?> showSongListOverviewSheet({
  required BuildContext context,
  required List<SongListEntryDto> entries,
  required int currentIndex,
}) {
  return showModalBottomSheet<int>(
    context: context,
    builder: (context) =>
        _OverviewSheet(entries: entries, currentIndex: currentIndex),
  );
}

class _OverviewSheet extends StatelessWidget {
  final List<SongListEntryDto> entries;
  final int currentIndex;

  const _OverviewSheet({required this.entries, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isCurrent = index == currentIndex;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: isCurrent
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            foregroundColor: isCurrent
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
            child: Text('${index + 1}'),
          ),
          title: Text(
            entry.songName,
            style: isCurrent
                ? const TextStyle(fontWeight: FontWeight.bold)
                : null,
          ),
          subtitle: Text(entry.songCode),
          selected: isCurrent,
          onTap: () => Navigator.pop(context, index),
        );
      },
    );
  }
}
