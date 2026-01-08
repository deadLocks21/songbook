import 'package:songbook/core/domain/model/song.dart' as domain_song;
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/song.repository.dart';

/// Implémentation du SongRepository utilisant Drift.
/// Récupère et gère les chants depuis la base de données SQLite.
/// Implémentation temporaire simplifiée - sera complétée avec Drift plus tard.
class DriftSongRepository implements SongRepository {
  final List<domain_song.Song> _songs = [];

  @override
  Future<List<domain_song.Song>> getAllSongs() async {
    return List.unmodifiable(_songs);
  }

  @override
  Future<void> addSong(domain_song.Song song) async {
    _songs.add(song);
  }

  @override
  Future<void> updateSong(domain_song.Song song) async {
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
