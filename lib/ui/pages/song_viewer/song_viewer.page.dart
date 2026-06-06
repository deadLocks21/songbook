import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/application/dtos/resource.dto.dart';
import 'package:songbook/core/application/dtos/song.dto.dart';
import 'package:songbook/core/domain/model/display_resource_type.dart';
import 'package:songbook/infrastructure/settings/providers/settings.service_provider.dart';
import 'package:songbook/ui/pages/chord_pro_viewer/chord_pro_viewer.page.dart';
import 'package:songbook/ui/pages/chord_pro_viewer/widgets/cached_chord_pro_viewer.widget.dart';
import 'package:songbook/ui/pages/song_viewer/widgets/cached_image_viewer.widget.dart';

/// Ordre d'affichage par défaut tant que la préférence n'est pas chargée.
const _defaultDisplayOrder = [
  DisplayResourceType.partition,
  DisplayResourceType.chordPro,
];

/// Page de visualisation des ressources d'un chant (partition image et/ou
/// fichier ChordPro).
///
/// Point d'entrée unique : si le chant possède plusieurs ressources
/// affichables, un sélecteur permet de basculer entre elles. La vue ouverte par
/// défaut suit la préférence « Priorité d'affichage » des réglages. Le contrôle
/// de transposition n'apparaît que pour la vue ChordPro.
class SongViewerPage extends ConsumerStatefulWidget {
  final SongDto song;
  final List<Widget>? actions;

  const SongViewerPage({super.key, required this.song, this.actions});

  @override
  ConsumerState<SongViewerPage> createState() => _SongViewerPageState();
}

class _SongViewerPageState extends ConsumerState<SongViewerPage> {
  /// Index de la vue sélectionnée parmi les ressources affichables.
  int _index = 0;

  /// Demi-tons de transposition pour la vue ChordPro.
  int _semitones = 0;

  /// Tonalité d'origine du fichier ChordPro (`{key:}`), une fois parsé, pour
  /// afficher la tonalité obtenue dans le contrôle de transposition. Un
  /// [ValueNotifier] (plutôt qu'un simple champ) pour qu'un panneau de
  /// transposition déjà ouvert se rafraîchisse dès que le parsing la résout.
  final ValueNotifier<String?> _originalKey = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _originalKey.dispose();
    super.dispose();
  }

  /// Première partition image non vide, le cas échéant.
  ImageResourceDto? get _image => widget.song.resources
      .whereType<ImageResourceDto>()
      .where((r) => r.imageUrls.isNotEmpty)
      .firstOrNull;

  /// Premier fichier ChordPro, le cas échéant.
  ChordProResourceDto? get _chordPro =>
      widget.song.resources.whereType<ChordProResourceDto>().firstOrNull;

  @override
  Widget build(BuildContext context) {
    final image = _image;
    final chordPro = _chordPro;
    final order =
        ref.watch(resourceDisplayOrderProvider).value ?? _defaultDisplayOrder;

    // Vues affichables, indexées par type. (Le PDF n'a pas de visionneuse, il
    // n'est donc pas listé.)
    final available = <DisplayResourceType, _View>{
      if (image != null)
        DisplayResourceType.partition: const _View(
          kind: DisplayResourceType.partition,
          label: 'Partition',
          icon: Icons.music_note,
        ),
      if (chordPro != null)
        DisplayResourceType.chordPro: const _View(
          kind: DisplayResourceType.chordPro,
          label: 'Accords',
          icon: Icons.lyrics,
        ),
    };

    // Ordonnées selon la préférence : la première disponible est la vue par
    // défaut (index 0).
    final views = [
      for (final type in order)
        if (available[type] case final view?) view,
    ];

    final index = views.isEmpty ? 0 : _index.clamp(0, views.length - 1);
    final current = views.isEmpty ? null : views[index].kind;

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.song.code,
              key: const Key('songCode'),
              style: theme.textTheme.titleLarge,
            ),
            Text(
              widget.song.name,
              key: const Key('songName'),
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        actions: [
          // Un seul bouton « Options » : choix de la vue (si plusieurs) et
          // transposition (en vue Accords) sont regroupés dans un panneau.
          if (views.length > 1 || current == DisplayResourceType.chordPro)
            IconButton(
              tooltip: 'Options',
              icon: const Icon(Icons.tune),
              onPressed: () => _openOptions(views),
            ),
          ...?widget.actions,
        ],
      ),
      body: _buildBody(current, image, chordPro),
    );
  }

  /// Ouvre le panneau d'options en bas de l'écran (barrière transparente, le
  /// contenu reste visible) : sélection de la vue puis, en vue Accords, les
  /// contrôles de transposition.
  void _openOptions(List<_View> views) {
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          final index = views.isEmpty ? 0 : _index.clamp(0, views.length - 1);
          final isChords =
              views.isNotEmpty &&
              views[index].kind == DisplayResourceType.chordPro;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              // Sans largeur explicite, le fond de la sheet se rétrécit à la
              // largeur du contenu (Column en min) et se centre : on force la
              // pleine largeur, contenu aligné à gauche.
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
                        child: SegmentedButton<int>(
                          segments: [
                            for (var i = 0; i < views.length; i++)
                              ButtonSegment<int>(
                                value: i,
                                label: Text(views[i].label),
                                icon: Icon(views[i].icon),
                              ),
                          ],
                          selected: {index},
                          onSelectionChanged: (selection) {
                            setState(() => _index = selection.first);
                            setSheetState(() {});
                          },
                        ),
                      ),
                    ],
                    if (views.length > 1) const SizedBox(height: 16),
                    // Toujours affichée, mais désactivée hors vue Accords.
                    // Le panneau peut être ouvert avant la fin du parsing : le
                    // ValueListenableBuilder le rafraîchit dès que la tonalité
                    // d'origine est résolue (sinon « 0 » resterait affiché
                    // jusqu'au premier +/-).
                    ValueListenableBuilder<String?>(
                      valueListenable: _originalKey,
                      builder: (context, originalKey, _) =>
                          ChordProTransposeControls(
                            enabled: isChords,
                            semitones: _semitones,
                            originalKey: originalKey,
                            onTranspose: (delta) {
                              setState(
                                () => _semitones = (_semitones + delta).clamp(
                                  -11,
                                  11,
                                ),
                              );
                              setSheetState(() {});
                            },
                          ),
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

  Widget _buildBody(
    DisplayResourceType? current,
    ImageResourceDto? image,
    ChordProResourceDto? chordPro,
  ) {
    switch (current) {
      case DisplayResourceType.partition:
        return CachedImageViewer(
          key: const Key('imageViewer'),
          songId: widget.song.id,
          imageUrls: image!.imageUrls,
        );
      case DisplayResourceType.chordPro:
        return CachedChordProViewer(
          key: const Key('chordProViewer'),
          songId: widget.song.id,
          chordProUrl: chordPro!.chordProUrl,
          semitones: _semitones,
          onOriginalKey: (key) => _originalKey.value = key,
        );
      case null:
        return const Center(
          key: Key('noImageMessage'),
          child: Text('Aucune partition disponible pour ce chant'),
        );
    }
  }
}

/// Décrit une vue affichable (libellé + icône) pour le sélecteur.
class _View {
  final DisplayResourceType kind;
  final String label;
  final IconData icon;

  const _View({required this.kind, required this.label, required this.icon});
}
