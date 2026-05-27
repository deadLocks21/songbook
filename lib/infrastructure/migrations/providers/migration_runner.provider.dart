import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/infrastructure/logger/providers/logger.service_provider.dart';
import 'package:songbook/infrastructure/migrations/migration_runner.dart';
import 'package:songbook/infrastructure/migrations/providers/migrations.provider.dart';

part 'migration_runner.provider.g.dart';

/// Assembles the [MigrationRunner] from the registry and the app logger.
/// Read it once from `main` to run pending migrations at startup.
@riverpod
MigrationRunner migrationRunner(Ref ref) {
  return MigrationRunner(
    ref.watch(migrationsProvider),
    ref.watch(loggerProvider),
  );
}
