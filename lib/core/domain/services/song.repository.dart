import 'package:songbook/core/domain/model/song.dart';

/// Interface pour accéder aux chants.
/// En lecture seule - expose simplement une liste de chants.
abstract interface class SongRepository {
  /// Récupère tous les chants disponibles.
  /// Retourne une liste non modifiable.
  Future<List<Song>> getAllSongs();
}
