import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:songbook/core/application/services/logger_application.service.dart';

/// Contract for a one-shot, idempotent **data** migration run at startup.
///
/// These are distinct from sqflite's schema versioning (`AppDatabase`'s
/// `onUpgrade`): the DDL — creating/altering tables — stays there. A
/// [Migration] handles *data* transforms that need to happen once on an
/// already-open database (back-filling a column, moving a value out of
/// SharedPreferences, normalising rows, …).
///
/// Implementations must be **idempotent**: [shouldRun] gates execution so a
/// migration that has already taken effect is a no-op even if its history
/// row was lost (DB recreated, table reset).
abstract class Migration {
  /// Stable, unique, immutable identifier. Used as the history primary key,
  /// so it must never change once a migration has shipped. Convention:
  /// `yyyy_MM_dd_snake_case_summary`, e.g. `2026_05_27_move_backend_url_to_db`.
  String get id;

  /// Whether this migration still has work to do. Called on every launch for
  /// migrations not yet recorded as succeeded; returning `false` records a
  /// `skipped` outcome and moves on. Keep this cheap and side-effect-free.
  Future<bool> shouldRun(MigrationContext ctx);

  /// Performs the migration. Only invoked when [shouldRun] returned `true`.
  /// Throwing is allowed — the runner records the failure and continues with
  /// the remaining migrations (log-and-continue).
  Future<void> execute(MigrationContext ctx);
}

/// Everything a [Migration] needs, passed explicitly rather than via `ref`
/// so migrations stay decoupled from Riverpod and trivially unit-testable.
class MigrationContext {
  final Database db;
  final LoggerApplicationService logger;

  const MigrationContext({required this.db, required this.logger});
}
