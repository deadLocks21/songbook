import 'package:songbook/core/domain/model/song.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';

/// Interface pour accéder et gérer les chants.
/// Expose les opérations de lecture et d'écriture.
abstract interface class SongRepository {
  /// Récupère tous les chants disponibles.
  /// Retourne une liste non modifiable.
  Future<List<Song>> getAllSongs();

  /// Ajoute un nouveau chant à la base de données.
  Future<void> addSong(Song song);

  /// Met à jour un chant existant.
  Future<void> updateSong(Song song);

  /// Supprime un chant par son identifiant.
  Future<void> deleteSong(UuidValue id);

  /// Supprime tous les chants de la base de données.
  Future<void> deleteAllSongs();
}
