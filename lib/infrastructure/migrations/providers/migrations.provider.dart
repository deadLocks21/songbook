import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/infrastructure/migrations/migration.dart';

part 'migrations.provider.g.dart';

/// Ordered registry of data migrations run at startup.
///
/// Append new migrations here, in the order they must run. Keep entries
/// forever once shipped (their history is keyed by [Migration.id]); never
/// reorder past migrations relative to ones already released.
@riverpod
List<Migration> migrations(Ref ref) => const [
  // e.g. Move2026_05_27BackendUrlToDb(),
];
