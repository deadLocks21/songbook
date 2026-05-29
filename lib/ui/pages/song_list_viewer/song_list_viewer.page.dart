import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/application/dtos/resource.dto.dart';
import 'package:songbook/core/application/dtos/song.dto.dart';
import 'package:songbook/ui/pages/chord_pro_viewer/chord_pro_viewer.page.dart';
import 'package:songbook/ui/pages/chord_pro_viewer/widgets/cached_chord_pro_viewer.widget.dart';
import 'package:songbook/ui/pages/song_list_viewer/providers/song_list_viewer.provider.dart';
import 'package:songbook/ui/pages/song_list_viewer/widgets/song_list_overview_sheet.widget.dart';
import 'package:songbook/ui/pages/song_viewer/widgets/cached_image_viewer.widget.dart';

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
  /// ChordPro. Remis à zéro à chaque changement de chant.
  int _semitones = 0;

  /// Première partition image non vide du chant, le cas échéant.
  ImageResourceDto? _imageOf(SongDto song) => song.resources
      .whereType<ImageResourceDto>()
      .where((r) => r.imageUrls.isNotEmpty)
      .firstOrNull;

  /// Premier fichier ChordPro du chant, le cas échéant.
  ChordProResourceDto? _chordProOf(SongDto song) =>
      song.resources.whereType<ChordProResourceDto>().firstOrNull;

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(songListViewerDataProvider(widget.songListId));

    return dataAsync.when(
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
        // Le chant est affiché en ChordPro (et transposable) quand il n'a pas
        // de partition image mais possède un fichier ChordPro.
        final showsChordPro = _imageOf(currentSong) == null &&
            _chordProOf(currentSong) != null;

        return Scaffold(
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
              _buildSongContent(currentSong),
              _buildNavigationOverlay(totalSongs),
            ],
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

  Widget _buildSongContent(SongDto song) {
    // Priorité à la partition image (comme la vue par défaut du sélecteur de
    // SongViewerPage), repli sur le ChordPro, sinon message d'absence.
    final image = _imageOf(song);
    if (image != null) {
      return CachedImageViewer(
        key: ValueKey('viewer_${_currentIndex}_${song.id}'),
        songId: song.id,
        imageUrls: image.imageUrls,
      );
    }

    final chordPro = _chordProOf(song);
    if (chordPro != null) {
      return CachedChordProViewer(
        key: ValueKey('viewerChordPro_${_currentIndex}_${song.id}'),
        songId: song.id,
        chordProUrl: chordPro.chordProUrl,
        semitones: _semitones,
      );
    }

    return const Center(
      child: Text('Aucune partition disponible pour ce chant'),
    );
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

  void _goToPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _semitones = 0;
      });
    }
  }

  void _goToNext() {
    final data = ref.read(songListViewerDataProvider(widget.songListId));
    final totalSongs = data.value?.songs.length ?? 0;
    if (_currentIndex < totalSongs - 1) {
      setState(() {
        _currentIndex++;
        _semitones = 0;
      });
    }
  }

  Future<void> _showOverview(SongListViewerData data) async {
    final selectedIndex = await showSongListOverviewSheet(
      context: context,
      entries: data.songList.entries,
      currentIndex: _currentIndex,
    );

    if (selectedIndex != null && mounted) {
      setState(() {
        _currentIndex = selectedIndex;
        _semitones = 0;
      });
    }
  }
}
