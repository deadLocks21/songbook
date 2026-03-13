import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/song_list.repository.dart';

/// Cas d'usage pour supprimer une liste de chants.
class DeleteSongListUseCase {
  final SongListRepository _repository;

  const DeleteSongListUseCase(this._repository);

  Future<void> execute(String songListId) async {
    await _repository.deleteSongList(UuidValue.parse(songListId));
  }
}
