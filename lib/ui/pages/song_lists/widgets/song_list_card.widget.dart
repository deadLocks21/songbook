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
  final VoidCallback? onUnfollow;

  const SongListCard({
    super.key,
    required this.songList,
    required this.onTap,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.onShare,
    this.onUnfollow,
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
                            _followedBadge(context),
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
  ///
  /// Aucune pastille « à mettre à jour » à côté : l'ouvrir suffit à récupérer
  /// ce qui a changé, donc annoncer un retard demanderait d'agir sur ce qui se
  /// règle tout seul en entrant.
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
        // Pas d'entrée « récupérer les changements » : ouvrir la liste suffit,
        // c'est ce qui déclenche la vérification. Un doublon manuel laisserait
        // croire qu'il faut y penser.
        if (onUnfollow != null && songList.isFollowing)
          const PopupMenuItem(
            value: 'unfollow',
            child: ListTile(
              leading: Icon(Icons.link_off),
              title: Text('Ne plus suivre'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        // Une liste suivie ne se repartage pas : elle appartient à quelqu'un
        // d'autre, et la transmettre depuis ici sèmerait la confusion sur qui
        // en est l'auteur.
        if (onShare != null && !songList.isFollowing)
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
      case 'unfollow':
        onUnfollow?.call();
      case 'share':
        onShare?.call();
      case 'delete':
        onDelete?.call();
    }
  }
}
