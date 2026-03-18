import 'package:songbook/core/application/dtos/song.dto.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';

class App {
  final List<SongDto> songs;
  final SongDto song;
  final List<SongListDto> songLists;

  App({required this.songs, required this.song, this.songLists = const []});
}
