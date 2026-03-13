import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/song.repository.dart';
import 'package:songbook/core/domain/services/song_list.repository.dart';

/// Cas d'usage pour recuperer le detail d'une liste de chants.
/// Resout les noms et codes des chants dans chaque entree.
class GetSongListDetailUseCase {
  final SongListRepository _songListRepository;
  final SongRepository _songRepository;

  const GetSongListDetailUseCase(
    this._songListRepository,
    this._songRepository,
  );

  Future<SongListDto?> execute(String songListId) async {
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
}
