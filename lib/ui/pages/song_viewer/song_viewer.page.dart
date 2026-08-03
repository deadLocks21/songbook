import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/application/dtos/resource.dto.dart';
import 'package:songbook/core/application/dtos/song.dto.dart';
import 'package:songbook/core/domain/model/display_resource_type.dart';
import 'package:songbook/core/domain/model/song_schedule.dart';
import 'package:songbook/infrastructure/settings/providers/settings.service_provider.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list.service_provider.dart';
import 'package:songbook/ui/pages/chord_pro_viewer/widgets/chord_pro_zoom_view.widget.dart';
import 'package:songbook/ui/pages/song_viewer/widgets/cached_image_viewer.widget.dart';
import 'package:songbook/ui/pages/song_viewer/widgets/song_history.sheet.dart';
import 'package:songbook/ui/pages/song_viewer/widgets/zoomable_image_viewer.widget.dart';
import 'package:songbook/ui/widgets/save_key_dialog.dart';
import 'package:songbook/ui/widgets/song_options_sheet.dart';

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

  /// Transposition appliquée à l'ouverture (demi-tons).
  final int initialSemitones;

  /// Appelé quand l'utilisateur confirme l'enregistrement de la transposition
  /// (via le dialog affiché en quittant la visionneuse). `null` = visionneuse
  /// simple, sans enregistrement de tonalité ni dialog.
  final ValueChanged<int>? onSemitonesChanged;

  const SongViewerPage({
    super.key,
    required this.song,
    this.actions,
    this.initialSemitones = 0,
    this.onSemitonesChanged,
  });

  @override
  ConsumerState<SongViewerPage> createState() => _SongViewerPageState();
}

class _SongViewerPageState extends ConsumerState<SongViewerPage> {
  /// Index de la vue sélectionnée parmi les ressources affichables.
  int _index = 0;

  /// Demi-tons de transposition pour la vue ChordPro.
  late int _semitones = widget.initialSemitones;

  /// Facteur de zoom du texte ChordPro (éphémère, propre à cette ouverture).
  double _textScale = 1.0;

  /// Niveau de zoom de la vue image (propre, séparé du zoom texte).
  double _imageScale = 1.0;

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

  /// `true` si la transposition a changé et qu'un enregistrement est possible
  /// (chant ouvert depuis une liste).
  bool get _isKeyDirty =>
      widget.onSemitonesChanged != null &&
      _semitones != widget.initialSemitones;

  /// Demande éventuellement à enregistrer la tonalité avant de quitter.
  /// Renvoie `true` si l'on peut quitter (enregistré ou abandonné), `false` si
  /// l'utilisateur annule.
  Future<bool> _confirmLeave() async {
    if (!_isKeyDirty) return true;
    final action = await showSaveKeyDialog(context);
    if (!mounted) return false;
    switch (action) {
      case SaveKeyAction.save:
        widget.onSemitonesChanged!.call(_semitones);
        return true;
      case SaveKeyAction.discard:
        return true;
      case SaveKeyAction.cancel:
      case null:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    final chordPro = _chordPro;
    final order =
        ref.watch(resourceDisplayOrderProvider).value ?? _defaultDisplayOrder;

    // Vues affichables, ordonnées selon la préférence : la première disponible
    // est la vue par défaut (index 0).
    final views = availableSongViews(
      hasImage: image != null,
      hasChordPro: chordPro != null,
      order: order,
    );

    final index = views.isEmpty ? 0 : _index.clamp(0, views.length - 1);
    final current = views.isEmpty ? null : views[index].type;

    // Suivi ici plutôt que lu au clic : l'historique arrive de façon
    // asynchrone, et le panneau doit s'ouvrir avec la réponse déjà en main.
    final schedule =
        ref.watch(songSchedulesProvider()).value?[widget.song.id] ??
        SongSchedule.never;

    final theme = Theme.of(context);
    return PopScope(
      canPop: !_isKeyDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmLeave() && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
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
            IconButton(
              key: const Key('songHistoryButton'),
              tooltip: 'Historique',
              icon: const Icon(Icons.history),
              onPressed: () => _openHistory(schedule),
            ),
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
      ),
    );
  }

  /// Ouvre l'historique de programmation du chant.
  ///
  /// Derrière un bouton plutôt qu'affiché en permanence : cette page sert
  /// d'abord à lire une partition, et l'historique n'intéresse qu'au moment de
  /// choisir. Il n'est jamais absent pour autant — un chant jamais pris le dit.
  void _openHistory(SongSchedule schedule) {
    showSongHistorySheet(
      context,
      songName: widget.song.name,
      schedule: schedule,
    );
  }

  /// Ouvre le panneau d'options partagé (sélecteur de vue + transposition +
  /// zoom). Le zoom contrôle la vue affichée à l'ouverture (texte ou image).
  void _openOptions(List<SongView> views) {
    final index = views.isEmpty ? 0 : _index.clamp(0, views.length - 1);
    final isImage = views[index].type == DisplayResourceType.partition;
    showSongOptionsSheet(
      context,
      views: views,
      selected: views[index].type,
      onSelectView: (type) => setState(
        () => _index = views.indexWhere((view) => view.type == type),
      ),
      semitones: _semitones,
      onTranspose: (delta) =>
          setState(() => _semitones = (_semitones + delta).clamp(-11, 11)),
      scale: isImage ? _imageScale : _textScale,
      onScaleChanged: (scale) => setState(() {
        if (isImage) {
          _imageScale = scale;
        } else {
          _textScale = scale;
        }
      }),
      minScale: isImage ? imageZoomMin : minChordProScale,
      maxScale: isImage ? imageZoomMax : maxChordProScale,
      scaleStep: isImage ? imageZoomStep : chordProScaleStep,
      originalKey: _originalKey,
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
          scale: _imageScale,
          onScaleChanged: (scale) => setState(() => _imageScale = scale),
        );
      case DisplayResourceType.chordPro:
        return ChordProZoomView(
          key: const Key('chordProViewer'),
          songId: widget.song.id,
          chordProUrl: chordPro!.chordProUrl,
          semitones: _semitones,
          onOriginalKey: (key) => _originalKey.value = key,
          textScale: _textScale,
          onTextScaleChanged: (scale) => setState(() => _textScale = scale),
        );
      case null:
        return const Center(
          key: Key('noImageMessage'),
          child: Text('Aucune partition disponible pour ce chant'),
        );
    }
  }
}
