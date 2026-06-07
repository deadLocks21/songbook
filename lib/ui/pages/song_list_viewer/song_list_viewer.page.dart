import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/application/dtos/resource.dto.dart';
import 'package:songbook/core/application/dtos/song.dto.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/core/domain/model/display_resource_type.dart';
import 'package:songbook/infrastructure/settings/providers/settings.service_provider.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list.service_provider.dart';
import 'package:songbook/ui/pages/chord_pro_viewer/chord_pro_viewer.page.dart';
import 'package:songbook/ui/pages/chord_pro_viewer/widgets/cached_chord_pro_viewer.widget.dart';
import 'package:songbook/ui/pages/song_list_viewer/providers/song_list_viewer.provider.dart';
import 'package:songbook/ui/pages/song_list_viewer/widgets/song_list_overview_sheet.widget.dart';
import 'package:songbook/ui/pages/song_viewer/widgets/cached_image_viewer.widget.dart';
import 'package:songbook/ui/widgets/save_key_dialog.dart';

/// Page de visualisation d'une liste de chants.
/// Affiche les partitions avec navigation precedent/suivant.
class SongListViewerPage extends ConsumerStatefulWidget {
  final String songListId;

  const SongListViewerPage({super.key, required this.songListId});

  @override
  ConsumerState<SongListViewerPage> createState() => _SongListViewerPageState();
}

class _SongListViewerPageState extends ConsumerState<SongListViewerPage> {
  int _currentIndex = 0;

  /// Demi-tons de transposition du chant courant lorsqu'il est affiché en
  /// ChordPro. Pré-rempli avec la tonalité enregistrée pour ce chant dans cette
  /// liste à chaque arrivée sur un chant.
  int _semitones = 0;

  /// Tonalité enregistrée (en demi-tons) du chant courant, telle que persistée
  /// pour cette liste. Sert de référence : la transposition est « modifiée »
  /// dès que [_semitones] s'en écarte. `null` = aucune tonalité enregistrée.
  int? _savedSemitones;

  /// Index pour lequel [_semitones]/[_savedSemitones] ont été pré-remplis.
  /// Évite de re-pré-remplir (et d'écraser une modification) à chaque build.
  int? _presetIndex;

  /// Verrou anti double-tap pendant l'attente d'une boîte de dialogue.
  bool _switching = false;

  /// Tonalité d'origine (`{key:}`) du chant courant, une fois parsé. Remise à
  /// zéro à chaque changement de chant, comme la transposition. Un
  /// [ValueNotifier] pour qu'un panneau de transposition déjà ouvert se
  /// rafraîchisse dès que le parsing la résout.
  final ValueNotifier<String?> _originalKey = ValueNotifier<String?>(null);

  /// Première partition image non vide du chant, le cas échéant.
  ImageResourceDto? _imageOf(SongDto song) => song.resources
      .whereType<ImageResourceDto>()
      .where((r) => r.imageUrls.isNotEmpty)
      .firstOrNull;

  /// Premier fichier ChordPro du chant, le cas échéant.
  ChordProResourceDto? _chordProOf(SongDto song) =>
      song.resources.whereType<ChordProResourceDto>().firstOrNull;

  /// Type de ressource affiché pour [song] : le premier disponible selon
  /// l'ordre de préférence [order], ou `null` si rien d'affichable.
  DisplayResourceType? _chosenTypeOf(
    SongDto song,
    List<DisplayResourceType> order,
  ) {
    final hasImage = _imageOf(song) != null;
    final hasChordPro = _chordProOf(song) != null;
    for (final type in order) {
      if (type == DisplayResourceType.partition && hasImage) return type;
      if (type == DisplayResourceType.chordPro && hasChordPro) return type;
    }
    return null;
  }

  @override
  void dispose() {
    _originalKey.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(songListViewerDataProvider(widget.songListId));
    final order =
        ref.watch(resourceDisplayOrderProvider).value ??
        const [DisplayResourceType.partition, DisplayResourceType.chordPro];

    return dataAsync.when(
      // Évite le spinner après une sauvegarde de tonalité (rafraîchissement du
      // provider) : on garde l'affichage courant pendant le rechargement.
      skipLoadingOnReload: true,
      data: (data) {
        if (data == null || data.songs.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Liste vide')),
            body: const Center(child: Text('Aucun chant dans cette liste')),
          );
        }

        // Clamp index in case songs were removed
        if (_currentIndex >= data.songs.length) {
          _currentIndex = data.songs.length - 1;
        }

        final currentSong = data.songs[_currentIndex];
        final totalSongs = data.songs.length;
        // Type affiché selon la préférence ; transposable seulement en ChordPro.
        final chosenType = _chosenTypeOf(currentSong, order);
        final showsChordPro = chosenType == DisplayResourceType.chordPro;

        // Pré-remplit la tonalité enregistrée à l'arrivée sur un chant
        // (chargement initial, ou index re-clampé après suppression). La
        // navigation explicite, elle, pré-remplit déjà de façon synchrone.
        if (_presetIndex != _currentIndex) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _applySavedKey(data, _currentIndex));
          });
        }

        return PopScope(
          canPop: !_isKeyDirty,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final shouldPop = await _confirmLeaveCurrentSong();
            if (shouldPop && context.mounted) Navigator.pop(context);
          },
          child: Scaffold(
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentSong.code,
                    key: const Key('viewerSongCode'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    currentSong.name,
                    key: const Key('viewerSongName'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              actions: [
                if (showsChordPro)
                  IconButton(
                    tooltip: 'Transposer',
                    icon: const Icon(Icons.tune),
                    onPressed: () => showChordProTransposeSheet(
                      context,
                      semitones: _semitones,
                      originalKey: _originalKey,
                      onTranspose: (delta) => setState(
                        () => _semitones = (_semitones + delta).clamp(-11, 11),
                      ),
                    ),
                  ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '${_currentIndex + 1}/$totalSongs',
                      key: const Key('viewerPositionIndicator'),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('viewerOverviewButton'),
                  icon: const Icon(Icons.list),
                  onPressed: () => _showOverview(data),
                  tooltip: 'Liste des chants',
                ),
              ],
            ),
            body: Stack(
              children: [
                _buildSongContent(currentSong, chosenType),
                _buildNavigationOverlay(totalSongs),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Erreur: $error')),
      ),
    );
  }

  Widget _buildSongContent(SongDto song, DisplayResourceType? type) {
    // Le type affiché suit la préférence « Priorité d'affichage » des réglages.
    switch (type) {
      case DisplayResourceType.partition:
        return CachedImageViewer(
          key: ValueKey('viewer_${_currentIndex}_${song.id}'),
          songId: song.id,
          imageUrls: _imageOf(song)!.imageUrls,
        );
      case DisplayResourceType.chordPro:
        return CachedChordProViewer(
          key: ValueKey('viewerChordPro_${_currentIndex}_${song.id}'),
          songId: song.id,
          chordProUrl: _chordProOf(song)!.chordProUrl,
          semitones: _semitones,
          onOriginalKey: (key) => _originalKey.value = key,
        );
      case null:
        return const Center(
          child: Text('Aucune partition disponible pour ce chant'),
        );
    }
  }

  Widget _buildNavigationOverlay(int totalSongs) {
    return Positioned.fill(
      child: Row(
        children: [
          // Bouton precedent
          if (_currentIndex > 0)
            GestureDetector(
              key: const Key('viewerPreviousButton'),
              onTap: _goToPrevious,
              child: Container(
                width: 48,
                color: Colors.transparent,
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: const Icon(Icons.chevron_left, color: Colors.white),
                ),
              ),
            )
          else
            const SizedBox(width: 48),
          const Spacer(),
          // Bouton suivant
          if (_currentIndex < totalSongs - 1)
            GestureDetector(
              key: const Key('viewerNextButton'),
              onTap: _goToNext,
              child: Container(
                width: 48,
                color: Colors.transparent,
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: const Icon(Icons.chevron_right, color: Colors.white),
                ),
              ),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  /// Positionne le chant [index] et pré-remplit sa transposition enregistrée.
  /// À appeler dans un `setState`.
  void _applySavedKey(SongListViewerData data, int index) {
    final saved = index >= 0 && index < data.entries.length
        ? data.entries[index].savedSemitones
        : null;
    _currentIndex = index;
    _savedSemitones = saved;
    _semitones = saved ?? 0;
    _presetIndex = index;
    _originalKey.value = null;
  }

  /// `true` si la transposition courante diffère de la tonalité enregistrée.
  bool get _isKeyDirty => _semitones != (_savedSemitones ?? 0);

  /// Demande éventuellement à sauvegarder avant de quitter le chant courant.
  /// Renvoie `true` si la navigation peut continuer (sauvegardé ou abandonné),
  /// `false` si l'utilisateur annule.
  Future<bool> _confirmLeaveCurrentSong() async {
    if (!_isKeyDirty) return true;
    final action = await showSaveKeyDialog(context);
    if (!mounted) return false;
    switch (action) {
      case SaveKeyAction.save:
        await _persistCurrentKey();
        return true;
      case SaveKeyAction.discard:
        return true;
      case SaveKeyAction.cancel:
      case null:
        return false;
    }
  }

  /// Persiste la transposition courante sur l'entrée du chant courant (0 demi-
  /// ton => aucune tonalité enregistrée), puis rafraîchit les providers.
  Future<void> _persistCurrentKey() async {
    final data = ref.read(songListViewerDataProvider(widget.songListId)).value;
    if (data == null || _currentIndex >= data.entries.length) return;

    final targetId = data.entries[_currentIndex].id;
    final newSaved = _semitones == 0 ? null : _semitones;

    // Construit l'entrée modifiée directement (et non via copyWith, qui ne sait
    // pas remettre un champ à null) pour pouvoir effacer une tonalité.
    final updatedEntries = data.songList.entries
        .map(
          (e) => e.id != targetId
              ? e
              : SongListEntryDto(
                  id: e.id,
                  songId: e.songId,
                  position: e.position,
                  savedSemitones: newSaved,
                  songCode: e.songCode,
                  songName: e.songName,
                ),
        )
        .toList();

    final dto = SongListDto(
      id: data.songList.id,
      scheduledAt: data.songList.scheduledAt,
      createdAt: data.songList.createdAt,
      entries: updatedEntries,
    );

    await ref.read(setlistServiceProvider).save(dto);
    if (!mounted) return;
    ref.invalidate(songListViewerDataProvider(widget.songListId));
    ref.invalidate(songListsProvider);
    // La nouvelle référence devient la valeur enregistrée : plus « modifié ».
    setState(() => _savedSemitones = newSaved);
  }

  Future<void> _goToPrevious() async {
    if (_switching || _currentIndex <= 0) return;
    _switching = true;
    try {
      if (!await _confirmLeaveCurrentSong() || !mounted) return;
      final data = ref
          .read(songListViewerDataProvider(widget.songListId))
          .value;
      if (data == null) return;
      setState(() => _applySavedKey(data, _currentIndex - 1));
    } finally {
      _switching = false;
    }
  }

  Future<void> _goToNext() async {
    if (_switching) return;
    final data = ref.read(songListViewerDataProvider(widget.songListId)).value;
    if (data == null || _currentIndex >= data.songs.length - 1) return;
    _switching = true;
    try {
      if (!await _confirmLeaveCurrentSong() || !mounted) return;
      setState(() => _applySavedKey(data, _currentIndex + 1));
    } finally {
      _switching = false;
    }
  }

  Future<void> _showOverview(SongListViewerData data) async {
    final selectedIndex = await showSongListOverviewSheet(
      context: context,
      entries: data.entries,
      currentIndex: _currentIndex,
    );

    if (selectedIndex == null || selectedIndex == _currentIndex || !mounted) {
      return;
    }
    if (!await _confirmLeaveCurrentSong() || !mounted) return;
    setState(() => _applySavedKey(data, selectedIndex));
  }
}
