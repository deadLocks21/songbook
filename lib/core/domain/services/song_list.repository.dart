import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';

/// Interface pour acceder et gerer les listes de chants.
/// Expose les operations de lecture et d'ecriture.
abstract interface class SongListRepository {
  /// Recupere toutes les listes de chants avec leurs entrees.
  Future<List<SongList>> getAllSongLists();

  /// Recupere une liste de chants par son identifiant.
  Future<SongList?> getSongListById(UuidValue id);

  /// Ajoute une nouvelle liste de chants avec ses entrees.
  Future<void> addSongList(SongList songList);

  /// Met a jour une liste existante et remplace toutes ses entrees.
  Future<void> updateSongList(SongList songList);

  /// Supprime une liste de chants et toutes ses entrees.
  Future<void> deleteSongList(UuidValue id);
}
