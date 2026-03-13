import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/core/domain/services/song.repository.dart';
import 'package:songbook/core/domain/services/song_list.repository.dart';

/// Cas d'usage pour recuperer toutes les listes de chants.
/// Resout les noms et codes des chants dans chaque entree.
class GetAllSongListsUseCase {
  final SongListRepository _songListRepository;
  final SongRepository _songRepository;

  const GetAllSongListsUseCase(this._songListRepository, this._songRepository);

  Future<List<SongListDto>> execute() async {
    final songLists = await _songListRepository.getAllSongLists();
    final songs = await _songRepository.getAllSongs();

    final songInfo = {
      for (final s in songs) s.id: (code: s.code, name: s.name),
    };

    final dtos = songLists
        .map((sl) => SongListDto.fromDomain(sl, songInfo))
        .toList();

    // Trier par scheduledAt decroissant (plus recent en premier)
    dtos.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

    return dtos;
  }
}
