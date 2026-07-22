import 'package:sqflite/sqflite.dart';
import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/song_list.repository.dart';
import 'package:songbook/infrastructure/song/drift/drift_database.dart';

/// Implementation du SongListRepository utilisant SQLite.
///
/// Chaque ligne porte son etat de synchro : `serverVersion` (version du canon
/// connue, NULL tant que la liste n'a jamais ete poussee), `dirty` et
/// `pendingDeletion` (la liste a ete supprimee ici, le serveur n'en sait rien
/// encore).
///
/// `dirty` compte les ecritures locales en attente plutot que de valoir 0 ou 1 :
/// une sauvegarde survenue pendant un envoi reseau incremente le compteur, donc
/// la fin de l'envoi ne peut pas declarer la liste « a jour » et perdre cette
/// derniere modification.
class DriftSongListRepository implements SongListRepository {
  /// Base à utiliser à la place de celle de l'application. Uniquement pour les
  /// tests, qui ouvrent une base en mémoire au même schéma.
  final Database? _database0;

  const DriftSongListRepository([this._database0]);

  Future<Database> get _database async => _database0 ?? await AppDatabase.database;

  @override
  Future<List<SongList>> getAllSongLists() async {
    final db = await _database;
    final listRows = await db.query(
      'song_lists',
      where: 'pendingDeletion = 0',
      orderBy: 'scheduledAt DESC',
    );

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
      where: 'id = ? AND pendingDeletion = 0',
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
        ..._listColumns(songList),
        'id': songList.id.value,
        'createdAt': songList.createdAt.toIso8601String(),
        'dirty': 1,
        'pendingDeletion': 0,
      });

      await _insertEntries(txn, songList);
    });
  }

  @override
  Future<void> updateSongList(SongList songList) async {
    final db = await _database;

    await db.transaction((txn) async {
      await _replaceEntries(txn, songList);

      await txn.rawUpdate(
        '''
        UPDATE song_lists
        SET scheduledAt = ?, title = ?, serverVersion = ?, createdAt = ?,
            dirty = dirty + 1
        WHERE id = ?
        ''',
        [
          songList.scheduledAt.toIso8601String(),
          songList.title,
          songList.version,
          songList.createdAt.toIso8601String(),
          songList.id.value,
        ],
      );
    });
  }

  @override
  Future<void> deleteSongList(UuidValue id) async {
    final db = await _database;

    final rows = await db.query(
      'song_lists',
      columns: ['serverVersion'],
      where: 'id = ?',
      whereArgs: [id.value],
    );
    final neverPushed =
        rows.isEmpty || rows.first['serverVersion'] == null;

    // Une liste jamais poussee n'existe que sur cet appareil : rien a propager,
    // on peut l'effacer pour de bon. Sinon on garde la ligne comme rappel qu'il
    // reste un DELETE a envoyer au serveur.
    if (neverPushed) {
      await purge(id);
      return;
    }

    await db.update(
      'song_lists',
      {'pendingDeletion': 1, 'dirty': 0},
      where: 'id = ?',
      whereArgs: [id.value],
    );
  }

  @override
  Future<List<({SongList list, int revision})>> getPendingPush() async {
    final db = await _database;
    final listRows = await db.query(
      'song_lists',
      where: 'dirty > 0 AND pendingDeletion = 0',
      orderBy: 'createdAt ASC',
    );

    final result = <({SongList list, int revision})>[];
    for (final row in listRows) {
      final entryRows = await db.query(
        'song_list_entries',
        where: 'songListId = ?',
        whereArgs: [row['id'] as String],
        orderBy: 'position ASC',
      );
      result.add((
        list: _listRowToDomain(row, entryRows.map(_entryRowToDomain).toList()),
        revision: row['dirty'] as int,
      ));
    }
    return result;
  }

  @override
  Future<List<UuidValue>> getPendingDeletions() async {
    final db = await _database;
    final rows = await db.query(
      'song_lists',
      columns: ['id'],
      where: 'pendingDeletion = 1',
    );

    return rows.map((row) => UuidValue.parse(row['id'] as String)).toList();
  }

  @override
  Future<void> markSynced(
    UuidValue id,
    int version, {
    required int revision,
  }) async {
    final db = await _database;

    // La version serveur est acquise dans tous les cas : c'est elle qui servira
    // de base au prochain envoi.
    await db.update(
      'song_lists',
      {'serverVersion': version},
      where: 'id = ?',
      whereArgs: [id.value],
    );

    // On ne solde que les modifications reellement envoyees. Si le compteur a
    // bouge entre-temps, ce qui a ete sauvegarde pendant l'envoi reste a
    // pousser.
    await db.update(
      'song_lists',
      {'dirty': 0},
      where: 'id = ? AND dirty = ?',
      whereArgs: [id.value, revision],
    );
  }

  @override
  Future<void> upsertFromRemote(SongList songList) async {
    final db = await _database;

    await db.transaction((txn) async {
      final existing = await txn.query(
        'song_lists',
        columns: ['dirty', 'pendingDeletion'],
        where: 'id = ?',
        whereArgs: [songList.id.value],
      );

      if (existing.isNotEmpty && _hasLocalChanges(existing.first)) {
        // Modifications locales en attente : elles gagnent, le canon sera
        // rattrape au prochain push.
        return;
      }

      final values = {
        ..._listColumns(songList),
        'createdAt': songList.createdAt.toIso8601String(),
        'dirty': 0,
        'pendingDeletion': 0,
      };

      if (existing.isEmpty) {
        await txn.insert('song_lists', {...values, 'id': songList.id.value});
      } else {
        await txn.update(
          'song_lists',
          values,
          where: 'id = ?',
          whereArgs: [songList.id.value],
        );
      }

      await _replaceEntries(txn, songList);
    });
  }

  @override
  Future<void> purge(UuidValue id) async {
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

  @override
  Future<void> applyRemoteDeletion(UuidValue id) async {
    final db = await _database;
    final rows = await db.query(
      'song_lists',
      columns: ['dirty', 'pendingDeletion'],
      where: 'id = ?',
      whereArgs: [id.value],
    );

    // Supprimee ailleurs mais modifiee ici : on garde la copie locale, le push
    // suivant la ressuscitera cote serveur.
    if (rows.isNotEmpty && _hasLocalChanges(rows.first)) return;

    await purge(id);
  }

  bool _hasLocalChanges(Map<String, dynamic> row) =>
      (row['dirty'] as int) > 0 && row['pendingDeletion'] == 0;

  /// Colonnes decrivant le contenu d'une liste, communes a l'insert et l'update.
  Map<String, dynamic> _listColumns(SongList songList) => {
    'scheduledAt': songList.scheduledAt.toIso8601String(),
    'title': songList.title,
    'serverVersion': songList.version,
  };

  Future<void> _replaceEntries(DatabaseExecutor txn, SongList songList) async {
    await txn.delete(
      'song_list_entries',
      where: 'songListId = ?',
      whereArgs: [songList.id.value],
    );
    await _insertEntries(txn, songList);
  }

  Future<void> _insertEntries(DatabaseExecutor txn, SongList songList) async {
    for (final entry in songList.entries) {
      await txn.insert('song_list_entries', {
        'id': entry.id.value,
        'songListId': songList.id.value,
        'songId': entry.songId.value,
        'position': entry.position,
        'savedSemitones': entry.savedSemitones,
      });
    }
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
      title: row['title'] as String?,
      version: row['serverVersion'] as int?,
    );
  }

  SongListEntry _entryRowToDomain(Map<String, dynamic> row) {
    return SongListEntry(
      id: UuidValue.parse(row['id'] as String),
      songId: UuidValue.parse(row['songId'] as String),
      position: row['position'] as int,
      savedSemitones: row['savedSemitones'] as int?,
    );
  }
}
