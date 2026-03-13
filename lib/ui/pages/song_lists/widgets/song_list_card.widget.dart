import 'package:flutter/material.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/ui/utils/date_format.dart';

/// Carte affichant une liste de chants dans la liste d'apercu.
/// Un appui long ou clic droit affiche un menu contextuel.
class SongListCard extends StatelessWidget {
  final SongListDto songList;
  final VoidCallback onTap;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SongListCard({
    super.key,
    required this.songList,
    required this.onTap,
    this.onView,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: GestureDetector(
        onSecondaryTapUp: (details) =>
            _showContextMenu(context, details.globalPosition),
        onLongPressStart: (details) =>
            _showContextMenu(context, details.globalPosition),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatDate(songList.scheduledAt),
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        '${songList.entries.length} chant${songList.entries.length > 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showContextMenu(BuildContext context, Offset position) async {
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx,
        position.dy,
      ),
      items: [
        if (onView != null && songList.entries.isNotEmpty)
          const PopupMenuItem(
            value: 'view',
            child: ListTile(
              leading: Icon(Icons.play_arrow),
              title: Text('Visionner'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (onEdit != null)
          const PopupMenuItem(
            value: 'edit',
            child: ListTile(
              leading: Icon(Icons.edit),
              title: Text('Éditer'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (onDelete != null)
          const PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete_outline),
              title: Text('Supprimer'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
      ],
    );

    switch (result) {
      case 'view':
        onView?.call();
      case 'edit':
        onEdit?.call();
      case 'delete':
        onDelete?.call();
    }
  }
}
