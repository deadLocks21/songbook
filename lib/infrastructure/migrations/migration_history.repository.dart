import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Outcome recorded for a migration on a given launch.
enum MigrationStatus { success, skipped, failed }

/// Persists which migrations have run, when, how long they took, and any
/// log/stacktrace — in a self-managed `schema_migrations` table.
///
/// One row per migration [id] (the primary key); the latest attempt
/// overwrites the previous one via `INSERT OR REPLACE`. That keeps the table
/// a clean snapshot of current state. If you ever need a full append-only
/// audit trail, swap the PK for a surrogate `rowid` and drop the `REPLACE`.
class MigrationHistoryRepository {
  static const _table = 'schema_migrations';

  final Database _db;

  const MigrationHistoryRepository(this._db);

  /// Creates the history table if it does not exist yet. Cheap to call on
  /// every launch; safe to run before any migration.
  Future<void> ensureTable() async {
    await _db.execute('''
      CREATE TABLE IF NOT EXISTS $_table (
        id          TEXT PRIMARY KEY,
        status      TEXT NOT NULL,
        ran_at      TEXT NOT NULL,
        duration_ms INTEGER,
        log         TEXT
      )
    ''');
  }

  /// Ids of migrations already recorded as [MigrationStatus.success]. Used to
  /// skip completed work without re-evaluating `shouldRun`.
  Future<Set<String>> succeededIds() async {
    final rows = await _db.query(
      _table,
      columns: ['id'],
      where: 'status = ?',
      whereArgs: [MigrationStatus.success.name],
    );
    return rows.map((r) => r['id'] as String).toSet();
  }

  /// Records (or replaces) the outcome of a migration run.
  Future<void> record(
    String id,
    MigrationStatus status, {
    int? durationMs,
    String? log,
  }) async {
    await _db.insert(_table, {
      'id': id,
      'status': status.name,
      'ran_at': DateTime.now().toUtc().toIso8601String(),
      'duration_ms': durationMs,
      'log': log,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
