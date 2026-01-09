import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:songbook/core/application/dtos/resource.dto.dart';
import 'package:songbook/core/application/dtos/song.dto.dart';

/// Page de visualisation des partitions d'un chant.
/// Affiche les images des ressources horizontalement avec un scroll libre.
/// Prend toute la hauteur disponible.
class SongViewerPage extends StatefulWidget {
  final SongDto song;

  const SongViewerPage({super.key, required this.song});

  @override
  State<SongViewerPage> createState() => _SongViewerPageState();
}

class _SongViewerPageState extends State<SongViewerPage> {
  @override
  Widget build(BuildContext context) {
    final imageResource = widget.song.resources
        .whereType<ImageResourceDto>()
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.song.code,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              widget.song.name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(context, imageResource),
    );
  }

  Widget _buildBody(BuildContext context, ImageResourceDto? imageResource) {
    if (imageResource == null || imageResource.imagePaths.isEmpty) {
      return const Center(
        child: Text('Aucune partition disponible pour ce chant'),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: imageResource.imagePaths.map((imagePath) {
              return SizedBox(
                height: constraints.maxHeight,
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'Erreur lors du chargement de la partition',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
