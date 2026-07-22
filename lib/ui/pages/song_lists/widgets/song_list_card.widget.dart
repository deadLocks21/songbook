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
  final VoidCallback? onShare;
  final VoidCallback? onPull;
  final VoidCallback? onUnfollow;

  /// La source a évolué depuis le dernier tirage.
  final bool hasUpstreamUpdate;

  const SongListCard({
    super.key,
    required this.songList,
    required this.onTap,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.onShare,
    this.onPull,
    this.onUnfollow,
    this.hasUpstreamUpdate = false,
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
                      Row(
                        children: [
                          Text(
                            '${songList.entries.length} chant${songList.entries.length > 1 ? 's' : ''}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (songList.isFollowing) ...[
                            const SizedBox(width: 8.0),
                            // Une seule pastille à la fois : « mise à jour »
                            // dit déjà que la liste est suivie, et l'empiler
                            // avec « suivie » noierait l'information utile.
                            hasUpstreamUpdate
                                ? _updateBadge(context)
                                : _followedBadge(context),
                          ],
                        ],
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

  /// Signale une liste reprise de quelqu'un d'autre. La copie est bien à
  /// l'utilisateur — il l'édite comme les siennes — mais savoir qu'elle a une
  /// source change ce qu'il en attend : elle peut évoluer en amont.
  Widget _followedBadge(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.link, size: 12.0, color: colors.onSecondaryContainer),
          const SizedBox(width: 4.0),
          Text(
            'Suivie',
            key: const Key('songListFollowedBadge'),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  /// Signale qu'il y a quelque chose à reprendre de la source. Plus visible que
  /// la pastille « suivie » : celle-ci décrit un état, celle-là appelle une
  /// action.
  Widget _updateBadge(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.arrow_downward, size: 12.0, color: colors.onPrimary),
          const SizedBox(width: 4.0),
          Text(
            'Mettre à jour',
            key: const Key('songListUpdateBadge'),
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: colors.onPrimary),
          ),
        ],
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
        if (onPull != null && songList.isFollowing)
          const PopupMenuItem(
            value: 'pull',
            child: ListTile(
              leading: Icon(Icons.arrow_downward),
              title: Text('Récupérer les changements'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (onUnfollow != null && songList.isFollowing)
          const PopupMenuItem(
            value: 'unfollow',
            child: ListTile(
              leading: Icon(Icons.link_off),
              title: Text('Ne plus suivre'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (onShare != null)
          const PopupMenuItem(
            value: 'share',
            child: ListTile(
              leading: Icon(Icons.ios_share),
              title: Text('Partager'),
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
      case 'pull':
        onPull?.call();
      case 'unfollow':
        onUnfollow?.call();
      case 'share':
        onShare?.call();
      case 'delete':
        onDelete?.call();
    }
  }
}
