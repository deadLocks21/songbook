import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/song.repository.dart';
import 'package:songbook/core/domain/services/song_list.repository.dart';

class SetlistService {
  final SongListRepository _songListRepository;
  final SongRepository _songRepository;

  const SetlistService(this._songListRepository, this._songRepository);

  Future<List<SongListDto>> getAllSetlists() async {
    final songLists = await _songListRepository.getAllSongLists();
    final songs = await _songRepository.getAllSongs();

    final songInfo = {
      for (final s in songs) s.id: (code: s.code, name: s.name),
    };

    final dtos = songLists
        .map((sl) => SongListDto.fromDomain(sl, songInfo))
        .toList();

    dtos.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

    return dtos;
  }

  Future<SongListDto?> getDetail(String songListId) async {
    final songList = await _songListRepository.getSongListById(
      UuidValue.parse(songListId),
    );
    if (songList == null) return null;

    final songIds = songList.entries.map((e) => e.songId).toList();
    final songs = await _songRepository.getSongsByIds(songIds);
    final songInfo = {
      for (final s in songs) s.id: (code: s.code, name: s.name),
    };

    return SongListDto.fromDomain(songList, songInfo);
  }

  Future<void> save(SongListDto dto) async {
    final songList = dto.toDomain();
    final existing = await _songListRepository.getSongListById(songList.id);

    if (existing != null) {
      await _songListRepository.updateSongList(songList);
    } else {
      await _songListRepository.addSongList(songList);
    }
  }

  Future<void> delete(String songListId) async {
    await _songListRepository.deleteSongList(UuidValue.parse(songListId));
  }
}
