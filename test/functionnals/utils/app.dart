import 'package:songbook/core/application/dtos/song.dto.dart';

class App {
  final List<SongDto> songs;
  final SongDto song;

  App({required this.songs, required this.song});
}
