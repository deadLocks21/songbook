import 'package:flutter/material.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/ui/utils/date_format.dart';

/// Carte affichant une liste de chants dans la liste d'apercu.
/// Le tap mène à la page d'édition/détail.
class SongListCard extends StatelessWidget {
  final SongListDto songList;
  final VoidCallback onTap;

  const SongListCard({
    super.key,
    required this.songList,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
    );
  }
}
