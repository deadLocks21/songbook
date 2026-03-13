import 'package:songbook/core/domain/model/song.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/song.repository.dart';

/// Implémentation en mémoire du SongRepository.
/// Utilisé pour le développement et les tests.
/// Contient des données d'exemple statiques.
class InMemorySongRepository implements SongRepository {
  final List<Song> _songs;

  InMemorySongRepository() : _songs = [];

  @override
  Future<List<Song>> getAllSongs() async {
    // Retourne une copie non modifiable
    return List.unmodifiable(_songs);
  }

  @override
  Future<List<Song>> getSongsByIds(List<UuidValue> ids) async {
    final idSet = ids.toSet();
    return List.unmodifiable(_songs.where((s) => idSet.contains(s.id)));
  }

  @override
  Future<void> addSong(Song song) async {
    _songs.add(song);
  }

  @override
  Future<void> updateSong(Song song) async {
    final index = _songs.indexWhere((s) => s.id == song.id);
    if (index != -1) {
      _songs[index] = song;
    }
  }

  @override
  Future<void> deleteSong(UuidValue id) async {
    _songs.removeWhere((s) => s.id == id);
  }

  @override
  Future<void> deleteAllSongs() async {
    _songs.clear();
  }
}
