import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/application/dtos/song.dto.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/infrastructure/song/providers/song.service_provider.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list.service_provider.dart';

part 'song_list_viewer.provider.g.dart';

/// Donnees resolues pour la visualisation d'une liste de chants.
class SongListViewerData {
  final SongListDto songList;
  final List<SongDto> songs;

  const SongListViewerData({required this.songList, required this.songs});
}

/// Provider qui resout une liste de chants en SongDto complets
/// (avec resources/images) pour la visualisation.
@riverpod
Future<SongListViewerData?> songListViewerData(
  Ref ref,
  String songListId,
) async {
  final songListService = ref.watch(songListServiceProvider);
  final songService = ref.watch(songServiceProvider);

  final detail = await songListService.getSongListDetail.execute(songListId);
  if (detail == null) return null;

  final allSongs = await songService.getAllSongs.execute();
  final songsById = {for (final s in allSongs) s.id: s};

  final resolvedSongs = detail.entries
      .map((entry) => songsById[entry.songId])
      .whereType<SongDto>()
      .toList();

  return SongListViewerData(songList: detail, songs: resolvedSongs);
}
