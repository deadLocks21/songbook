import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/application/dtos/song.dto.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/infrastructure/song/providers/song.service_provider.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list.service_provider.dart';

part 'song_list_viewer.provider.g.dart';

/// Donnees resolues pour la visualisation d'une liste de chants.
class SongListViewerData {
  final SongListDto songList;

  /// Entrees dont le chant a ete retrouve dans le catalogue, alignees position
  /// par position avec [songs] (meme index = meme chant).
  final List<SongListEntryDto> entries;

  final List<SongDto> songs;

  const SongListViewerData({
    required this.songList,
    required this.entries,
    required this.songs,
  });
}

/// Provider qui resout une liste de chants en SongDto complets
/// (avec resources/images) pour la visualisation.
@riverpod
Future<SongListViewerData?> songListViewerData(
  Ref ref,
  String songListId,
) async {
  final setlistService = ref.watch(setlistServiceProvider);
  final songCatalogService = await ref.watch(songCatalogServiceProvider.future);

  final detail = await setlistService.getDetail(songListId);
  if (detail == null) return null;

  final allSongs = await songCatalogService.getAllSongs();
  final songsById = {for (final s in allSongs) s.id: s};

  // Garde les entrees et les chants alignes : on ignore une entree dont le
  // chant a disparu du catalogue, mais on conserve la correspondance d'index
  // entre entree et chant (necessaire pour lire/ecrire la tonalite enregistree).
  final resolvedEntries = <SongListEntryDto>[];
  final resolvedSongs = <SongDto>[];
  for (final entry in detail.entries) {
    final song = songsById[entry.songId];
    if (song == null) continue;
    resolvedEntries.add(entry);
    resolvedSongs.add(song);
  }

  return SongListViewerData(
    songList: detail,
    entries: resolvedEntries,
    songs: resolvedSongs,
  );
}
