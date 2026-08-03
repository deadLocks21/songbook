import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/core/domain/model/upstream_link.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/infrastructure/song/drift/drift_database.dart';
import 'package:songbook/infrastructure/song_list/drift.song_list.repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// La migration du schéma local, rejouée sur une base qui contient déjà des
/// données.
///
/// C'est le seul endroit où une erreur se paie chez l'utilisateur plutôt qu'au
/// build : une migration fautive s'exécute sur son appareil, sur ses listes, et
/// il n'a aucun moyen de revenir en arrière.
void main() {
  late Database db;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);
    await _createVersion4Schema(db);
  });

  tearDown(() => db.close());

  group('Migration du schéma des listes en version 5', () {
    test('conserve les listes déjà présentes', () async {
      await _insertVersion4List(db);

      await AppDatabase.migrate(db, 4, 5);

      final stored = await DriftSongListRepository(db).getSongListById(listId);
      expect(stored, isNotNull);
      expect(stored!.title, 'Dimanche');
      expect(stored.version, 3);
      expect(stored.entries.single.songId, songId);
    });

    test('laisse les listes existantes sans lien amont', () async {
      // Rien à reprendre : avant la v5, aucune liste n'était la copie d'une
      // autre. Un backfill inventerait des abonnements.
      await _insertVersion4List(db);

      await AppDatabase.migrate(db, 4, 5);

      final stored = await DriftSongListRepository(db).getSongListById(listId);
      expect(stored!.upstream, isNull);
      expect(stored.isFollowing, isFalse);
    });

    test('rend la base capable de suivre une liste', () async {
      await _insertVersion4List(db);

      await AppDatabase.migrate(db, 4, 5);

      final repository = DriftSongListRepository(db);
      final stored = (await repository.getSongListById(listId))!;
      await repository.updateSongList(
        stored.copyWith(
          upstream: UpstreamLink(sourceListId: sourceId, sourceVersion: 7),
        ),
      );

      expect((await repository.findCopyOf(sourceId))?.id, listId);
    });

    test('crée les tables d\'instantané amont', () async {
      await AppDatabase.migrate(db, 4, 5);

      final tables = await db.query(
        'sqlite_master',
        columns: ['name'],
        where: 'type = ? AND name LIKE ?',
        whereArgs: ['table', 'song_list_upstream%'],
      );

      expect(
        tables.map((r) => r['name']),
        containsAll([
          'song_list_upstream_snapshots',
          'song_list_upstream_snapshot_entries',
        ]),
      );
    });
  });
}

final listId = UuidValue.parse('11111111-1111-4111-8111-111111111111');
final entryId = UuidValue.parse('22222222-2222-4222-8222-222222222222');
final songId = UuidValue.parse('33333333-3333-4333-8333-333333333333');
final sourceId = UuidValue.parse('55555555-5555-4555-8555-555555555555');

/// Le schéma tel qu'il était livré en version 4, recopié à la main : c'est
/// justement l'état qu'on ne peut plus produire depuis le code courant.
Future<void> _createVersion4Schema(Database db) async {
  await db.execute('''
    CREATE TABLE song_lists (
      id TEXT PRIMARY KEY,
      scheduledAt TEXT NOT NULL,
      createdAt TEXT NOT NULL,
      title TEXT,
      serverVersion INTEGER,
      dirty INTEGER NOT NULL DEFAULT 1,
      pendingDeletion INTEGER NOT NULL DEFAULT 0
    )
  ''');

  await db.execute('''
    CREATE TABLE song_list_entries (
      id TEXT PRIMARY KEY,
      songListId TEXT NOT NULL,
      songId TEXT NOT NULL,
      position INTEGER NOT NULL,
      savedSemitones INTEGER
    )
  ''');
}

Future<void> _insertVersion4List(Database db) async {
  await db.insert('song_lists', {
    'id': listId.value,
    'scheduledAt': DateTime(2026, 8, 2).toIso8601String(),
    'createdAt': DateTime(2026, 7, 21).toIso8601String(),
    'title': 'Dimanche',
    'serverVersion': 3,
    'dirty': 0,
    'pendingDeletion': 0,
  });

  await db.insert('song_list_entries', {
    'id': entryId.value,
    'songListId': listId.value,
    'songId': songId.value,
    'position': 0,
    'savedSemitones': 2,
  });
}
