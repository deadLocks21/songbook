import 'package:flutter/material.dart';
import 'package:songbook/core/application/dtos/resource.dto.dart';
import 'package:songbook/core/application/dtos/song.dto.dart';
import 'package:songbook/ui/pages/song_viewer/zoomable_image_viewer.dart';

/// Page de visualisation des partitions d'un chant.
class SongViewerPage extends StatelessWidget {
  final SongDto song;

  const SongViewerPage({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final imageResource =
        song.resources.whereType<ImageResourceDto>().firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              song.code,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              song.name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
      ),
      body: _buildBody(imageResource),
    );
  }

  Widget _buildBody(ImageResourceDto? imageResource) {
    if (imageResource == null || imageResource.imagePaths.isEmpty) {
      return const Center(
        child: Text('Aucune partition disponible pour ce chant'),
      );
    }

    return ZoomableImageViewer(imagePaths: imageResource.imagePaths);
  }
}
