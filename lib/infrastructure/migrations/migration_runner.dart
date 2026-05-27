import 'package:songbook/core/application/services/logger_application.service.dart';
import 'package:songbook/infrastructure/migrations/migration.dart';
import 'package:songbook/infrastructure/migrations/migration_history.repository.dart';
import 'package:songbook/infrastructure/song/drift/drift_database.dart';

/// Runs the registered data [Migration]s once at startup.
///
/// Strategy is **log-and-continue**: a failing migration is recorded and
/// logged, then the runner moves on to the next one so a single bad
/// migration never bricks startup. Migrations run in registration order, so
/// the registry list must stay ordered if later migrations depend on earlier
/// ones.
class MigrationRunner {
  final List<Migration> _migrations;
  final LoggerApplicationService _logger;

  const MigrationRunner(this._migrations, this._logger);

  /// Opens the database, ensures the history table exists, then evaluates and
  /// runs each pending migration. Never throws: any per-migration failure is
  /// caught and recorded.
  Future<void> run() async {
    if (_migrations.isEmpty) return;

    final db = await AppDatabase.database;
    final history = MigrationHistoryRepository(db);
    await history.ensureTable();

    final done = await history.succeededIds();
    final ctx = MigrationContext(db: db, logger: _logger);

    for (final migration in _migrations) {
      final id = migration.id;
      if (done.contains(id)) continue;

      final sw = Stopwatch()..start();
      try {
        if (!await migration.shouldRun(ctx)) {
          sw.stop();
          await history.record(
            id,
            MigrationStatus.skipped,
            durationMs: sw.elapsedMilliseconds,
          );
          continue;
        }

        await migration.execute(ctx);
        sw.stop();
        await history.record(
          id,
          MigrationStatus.success,
          durationMs: sw.elapsedMilliseconds,
        );
        _logger.info(
          'migration.applied',
          attrs: {'migration.id': id, 'migration.duration_ms': sw.elapsedMilliseconds},
        );
      } catch (e, stack) {
        sw.stop();
        await history.record(
          id,
          MigrationStatus.failed,
          durationMs: sw.elapsedMilliseconds,
          log: '$e\n$stack',
        );
        _logger.error(
          'migration.failed',
          attrs: {'migration.id': id},
          error: e,
          stack: stack,
        );
        // log-and-continue: keep going with the remaining migrations.
      }
    }
  }
}
