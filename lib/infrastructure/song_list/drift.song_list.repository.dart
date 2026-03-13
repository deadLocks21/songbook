import 'package:sqflite/sqflite.dart';
import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/song_list.repository.dart';
import 'package:songbook/infrastructure/song/drift/drift_database.dart';

/// Implementation du SongListRepository utilisant SQLite.
class DriftSongListRepository implements SongListRepository {
  const DriftSongListRepository();
  Future<Database> get _database => AppDatabase.database;

  @override
  Future<List<SongList>> getAllSongLists() async {
    final db = await _database;
    final listRows = await db.query('song_lists', orderBy: 'scheduledAt DESC');

    final allEntryRows = await db.query(
      'song_list_entries',
      orderBy: 'songListId, position ASC',
    );

    final entriesByListId = <String, List<SongListEntry>>{};
    for (final row in allEntryRows) {
      final listId = row['songListId'] as String;
      (entriesByListId[listId] ??= []).add(_entryRowToDomain(row));
    }

    return listRows.map((row) {
      final listId = row['id'] as String;
      return _listRowToDomain(row, entriesByListId[listId] ?? []);
    }).toList();
  }

  @override
  Future<SongList?> getSongListById(UuidValue id) async {
    final db = await _database;
    final rows = await db.query(
      'song_lists',
      where: 'id = ?',
      whereArgs: [id.value],
    );

    if (rows.isEmpty) return null;

    final entryRows = await db.query(
      'song_list_entries',
      where: 'songListId = ?',
      whereArgs: [id.value],
      orderBy: 'position ASC',
    );

    return _listRowToDomain(
      rows.first,
      entryRows.map(_entryRowToDomain).toList(),
    );
  }

  @override
  Future<void> addSongList(SongList songList) async {
    final db = await _database;

    await db.transaction((txn) async {
      await txn.insert('song_lists', {
        'id': songList.id.value,
        'scheduledAt': songList.scheduledAt.toIso8601String(),
        'createdAt': songList.createdAt.toIso8601String(),
      });

      for (final entry in songList.entries) {
        await txn.insert('song_list_entries', {
          'id': entry.id.value,
          'songListId': songList.id.value,
          'songId': entry.songId.value,
          'position': entry.position,
        });
      }
    });
  }

  @override
  Future<void> updateSongList(SongList songList) async {
    final db = await _database;

    await db.transaction((txn) async {
      // Supprimer les anciennes entrees
      await txn.delete(
        'song_list_entries',
        where: 'songListId = ?',
        whereArgs: [songList.id.value],
      );

      // Mettre a jour la liste
      await txn.update(
        'song_lists',
        {
          'scheduledAt': songList.scheduledAt.toIso8601String(),
          'createdAt': songList.createdAt.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [songList.id.value],
      );

      // Inserer les nouvelles entrees
      for (final entry in songList.entries) {
        await txn.insert('song_list_entries', {
          'id': entry.id.value,
          'songListId': songList.id.value,
          'songId': entry.songId.value,
          'position': entry.position,
        });
      }
    });
  }

  @override
  Future<void> deleteSongList(UuidValue id) async {
    final db = await _database;

    await db.transaction((txn) async {
      await txn.delete(
        'song_list_entries',
        where: 'songListId = ?',
        whereArgs: [id.value],
      );
      await txn.delete('song_lists', where: 'id = ?', whereArgs: [id.value]);
    });
  }

  SongList _listRowToDomain(
    Map<String, dynamic> row,
    List<SongListEntry> entries,
  ) {
    return SongList(
      id: UuidValue.parse(row['id'] as String),
      scheduledAt: DateTime.parse(row['scheduledAt'] as String),
      createdAt: DateTime.parse(row['createdAt'] as String),
      entries: entries,
    );
  }

  SongListEntry _entryRowToDomain(Map<String, dynamic> row) {
    return SongListEntry(
      id: UuidValue.parse(row['id'] as String),
      songId: UuidValue.parse(row['songId'] as String),
      position: row['position'] as int,
    );
  }
}
