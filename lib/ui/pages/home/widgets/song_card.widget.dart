import 'package:flutter/material.dart';
import 'package:songbook/core/application/dtos/resource.dto.dart';
import 'package:songbook/core/application/dtos/song.dto.dart';
import 'package:songbook/core/domain/model/song_schedule.dart';
import 'package:songbook/ui/pages/song_viewer/song_viewer.page.dart';
import 'package:songbook/ui/widgets/song_schedule_label.widget.dart';
import 'package:songbook/ui/widgets/song_title.widget.dart';

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

  /// Ce que les listes de l'appareil disent de ce chant. Reçu d'en haut plutôt
  /// que lu ici : la grille le lit une fois pour toutes ses cartes.
  final SongSchedule schedule;

  const SongCard({
    super.key,
    required this.song,
    this.schedule = SongSchedule.never,
  });

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
              // Même présentation que dans le sélecteur : le code devant le
              // titre, en plus petit. Il ne prend plus sa propre ligne, ce qui
              // laisse la place à l'historique sans agrandir la carte.
              SongTitle(
                code: song.code,
                name: song.name,
                nameStyle: Theme.of(context).textTheme.bodyLarge,
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
              const SizedBox(height: 6.0),
              SongScheduleLabel(
                key: Key('songSchedule_${song.id}'),
                schedule: schedule,
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
