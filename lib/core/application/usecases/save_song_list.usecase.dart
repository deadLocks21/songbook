import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/core/domain/services/song_list.repository.dart';

/// Cas d'usage pour creer ou mettre a jour une liste de chants.
/// Renumerote les positions des entrees a la sauvegarde.
class SaveSongListUseCase {
  final SongListRepository _repository;

  const SaveSongListUseCase(this._repository);

  Future<void> execute(SongListDto dto) async {
    final songList = dto.toDomain();
    final existing = await _repository.getSongListById(songList.id);

    if (existing != null) {
      await _repository.updateSongList(songList);
    } else {
      await _repository.addSongList(songList);
    }
  }
}
