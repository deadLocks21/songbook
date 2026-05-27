// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'migration_runner.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Assembles the [MigrationRunner] from the registry and the app logger.
/// Read it once from `main` to run pending migrations at startup.

@ProviderFor(migrationRunner)
final migrationRunnerProvider = MigrationRunnerProvider._();

/// Assembles the [MigrationRunner] from the registry and the app logger.
/// Read it once from `main` to run pending migrations at startup.

final class MigrationRunnerProvider
    extends
        $FunctionalProvider<MigrationRunner, MigrationRunner, MigrationRunner>
    with $Provider<MigrationRunner> {
  /// Assembles the [MigrationRunner] from the registry and the app logger.
  /// Read it once from `main` to run pending migrations at startup.
  MigrationRunnerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'migrationRunnerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$migrationRunnerHash();

  @$internal
  @override
  $ProviderElement<MigrationRunner> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MigrationRunner create(Ref ref) {
    return migrationRunner(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MigrationRunner value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MigrationRunner>(value),
    );
  }
}

String _$migrationRunnerHash() => r'02cae6c671c4c7b9dd953adb09eb36d8a45a2538';
