import 'package:flutter/material.dart';
import 'package:songbook/core/application/dtos/resource.dto.dart';
import 'package:songbook/core/application/dtos/song.dto.dart';
import 'package:songbook/ui/pages/song_viewer/widgets/cached_image_viewer.widget.dart';

/// Page de visualisation des partitions d'un chant.
class SongViewerPage extends StatelessWidget {
  final SongDto song;
  final List<Widget>? actions;

  const SongViewerPage({super.key, required this.song, this.actions});

  @override
  Widget build(BuildContext context) {
    final imageResource = song.resources
        .whereType<ImageResourceDto>()
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              song.code,
              key: const Key('songCode'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              song.name,
              key: const Key('songName'),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        actions: actions,
      ),
      body: _buildBody(imageResource),
    );
  }

  Widget _buildBody(ImageResourceDto? imageResource) {
    if (imageResource == null || imageResource.imageUrls.isEmpty) {
      return const Center(
        key: Key('noImageMessage'),
        child: Text('Aucune partition disponible pour ce chant'),
      );
    }

    return CachedImageViewer(
      key: const Key('imageViewer'),
      songId: song.id,
      imageUrls: imageResource.imageUrls,
    );
  }
}
