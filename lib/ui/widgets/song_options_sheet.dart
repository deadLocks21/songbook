import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:songbook/core/domain/model/display_resource_type.dart';
import 'package:songbook/ui/pages/chord_pro_viewer/chord_pro_viewer.page.dart';

/// Vue affichable d'un chant (type + libellé + icône) pour le sélecteur.
class SongView {
  final DisplayResourceType type;
  final String label;
  final IconData icon;

  const SongView({required this.type, required this.label, required this.icon});
}

const _partitionView = SongView(
  type: DisplayResourceType.partition,
  label: 'Partition',
  icon: Icons.music_note,
);
const _chordProView = SongView(
  type: DisplayResourceType.chordPro,
  label: 'Accords',
  icon: Icons.lyrics,
);

/// Vues affichables d'un chant, ordonnées selon la préférence [order].
/// (Le PDF n'a pas de visionneuse, il n'est donc pas listé.)
List<SongView> availableSongViews({
  required bool hasImage,
  required bool hasChordPro,
  required List<DisplayResourceType> order,
}) {
  final available = <DisplayResourceType, SongView>{
    if (hasImage) DisplayResourceType.partition: _partitionView,
    if (hasChordPro) DisplayResourceType.chordPro: _chordProView,
  };
  return [
    for (final type in order)
      if (available[type] case final view?) view,
  ];
}

/// Panneau d'options partagé affiché en bas de l'écran (barrière transparente,
/// le contenu reste visible) : sélecteur de vue (si plusieurs vues) puis
/// contrôles de transposition, toujours affichés mais désactivés hors vue
/// Accords.
///
/// Commun à la visionneuse de chant et à la vue liste (édition/présentation).
/// Le panneau garde son état local (vue sélectionnée + demi-tons) et remonte les
/// changements via [onSelectView] et [onTranspose] (delta), comme
/// [showChordProTransposeSheet]. [originalKey] permet d'afficher la tonalité
/// obtenue ; il peut être résolu après l'ouverture du panneau.
Future<void> showSongOptionsSheet(
  BuildContext context, {
  required List<SongView> views,
  required DisplayResourceType selected,
  required ValueChanged<DisplayResourceType> onSelectView,
  required int semitones,
  required ValueChanged<int> onTranspose,
  ValueListenable<String?>? originalKey,
}) {
  var selectedType = selected;
  var currentSemitones = semitones;

  return showModalBottomSheet<void>(
    context: context,
    barrierColor: Colors.transparent,
    builder: (_) => StatefulBuilder(
      builder: (context, setSheetState) {
        final theme = Theme.of(context);
        final isChords = selectedType == DisplayResourceType.chordPro;

        ChordProTransposeControls controls(String? key) =>
            ChordProTransposeControls(
              enabled: isChords,
              semitones: currentSemitones,
              originalKey: key,
              onTranspose: (delta) {
                currentSemitones = (currentSemitones + delta).clamp(-11, 11);
                onTranspose(delta);
                setSheetState(() {});
              },
            );

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            // Largeur forcée : sinon le fond se rétrécit au contenu et se centre.
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (views.length > 1) ...[
                    Text('Vue', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<DisplayResourceType>(
                        segments: [
                          for (final view in views)
                            ButtonSegment<DisplayResourceType>(
                              value: view.type,
                              label: Text(view.label),
                              icon: Icon(view.icon),
                            ),
                        ],
                        selected: {selectedType},
                        onSelectionChanged: (selection) {
                          selectedType = selection.first;
                          onSelectView(selectedType);
                          setSheetState(() {});
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Le panneau peut être ouvert avant la fin du parsing : le
                  // ValueListenableBuilder rafraîchit la tonalité dès qu'elle est
                  // résolue.
                  if (originalKey == null)
                    controls(null)
                  else
                    ValueListenableBuilder<String?>(
                      valueListenable: originalKey,
                      builder: (context, key, _) => controls(key),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
