import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/song_list.repository.dart';

/// Implémentation en mémoire du SongListRepository.
/// Utilisé pour le web et les tests.
class InMemorySongListRepository implements SongListRepository {
  final List<SongList> _songLists;

  InMemorySongListRepository() : _songLists = [];

  @override
  Future<List<SongList>> getAllSongLists() async {
    return List.unmodifiable(_songLists);
  }

  @override
  Future<SongList?> getSongListById(UuidValue id) async {
    final index = _songLists.indexWhere((s) => s.id == id);
    if (index == -1) return null;
    return _songLists[index];
  }

  @override
  Future<void> addSongList(SongList songList) async {
    _songLists.add(songList);
  }

  @override
  Future<void> updateSongList(SongList songList) async {
    final index = _songLists.indexWhere((s) => s.id == songList.id);
    if (index != -1) {
      _songLists[index] = songList;
    }
  }

  @override
  Future<void> deleteSongList(UuidValue id) async {
    _songLists.removeWhere((s) => s.id == id);
  }
}
