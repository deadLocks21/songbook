import 'package:songbook/core/application/dtos/song.dto.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';

import '../functionnals/utils/app.dart';

class AppBuilder {
  List<SongDto> _songs = [];
  List<SongListDto> _songLists = [];
  SongDto _song = SongDto(
    id: '00000000-0000-4000-a000-000000000001',
    code: 'C001',
    name: 'Amazing Grace',
    updatedAt: DateTime.now(),
    resources: [],
  );

  AppBuilder withSongsList(List<SongDto> songs) {
    _songs = songs;
    return this;
  }

  AppBuilder withSong(SongDto song) {
    _song = song;
    if (_songs.contains(song)) {
      return this;
    }
    _songs.add(song);
    return this;
  }

  AppBuilder withSongLists(List<SongListDto> songLists) {
    _songLists = songLists;
    return this;
  }

  AppBuilder withSongList(SongListDto songList) {
    _songLists.add(songList);
    return this;
  }

  App build() {
    return App(songs: _songs, song: _song, songLists: _songLists);
  }
}
