import 'package:songbook/core/domain/model/song.dart' as domain_song;
import 'package:songbook/core/domain/services/song.repository.dart';

/// Implémentation du SongRepository utilisant Drift.
/// En lecture seule - récupère les chants depuis la base de données SQLite.
/// Implémentation temporaire simplifiée.
class DriftSongRepository implements SongRepository {
  @override
  Future<List<domain_song.Song>> getAllSongs() async {
    // Implémentation temporaire: retourne une liste vide
    // Sera remplacée par une vraie implémentation Drift plus tard
    return [];
  }
}
