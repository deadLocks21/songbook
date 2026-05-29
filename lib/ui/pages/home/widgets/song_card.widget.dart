import 'package:flutter/material.dart';
import 'package:songbook/core/application/dtos/resource.dto.dart';
import 'package:songbook/core/application/dtos/song.dto.dart';
import 'package:songbook/ui/pages/song_viewer/song_viewer.page.dart';

/// Extension pour ajouter des propriétés calculées à SongDto.
extension SongDtoExtension on SongDto {
  /// Vérifie si ce chant contient des ressources image.
  bool get hasImage =>
      resources.any((resource) => resource is ImageResourceDto);

  /// Vérifie si ce chant contient des ressources PDF.
  bool get hasPdf => resources.any((resource) => resource is PdfResourceDto);

  /// Vérifie si ce chant contient un fichier ChordPro.
  bool get hasChordPro =>
      resources.any((resource) => resource is ChordProResourceDto);
}

/// Carte affichant un chant dans la grille.
class SongCard extends StatelessWidget {
  final SongDto song;

  const SongCard({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('songCard_${song.id}'),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SongViewerPage(song: song)),
          );
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(song.code, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 2.0),
              Text(
                song.name,
                style: Theme.of(context).textTheme.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  if (song.hasImage) _ResourceIcon(icon: Icons.music_note),
                  if (song.hasPdf) _ResourceIcon(icon: Icons.list),
                  if (song.hasChordPro) _ResourceIcon(icon: Icons.lyrics),
                  if (song.resources.isEmpty)
                    Text(
                      'Aucune ressource',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Icône représentant un type de ressource.
class _ResourceIcon extends StatelessWidget {
  final IconData icon;

  const _ResourceIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Icon(icon, size: 16),
    );
  }
}
