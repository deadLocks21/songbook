// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'migrations.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Ordered registry of data migrations run at startup.
///
/// Append new migrations here, in the order they must run. Keep entries
/// forever once shipped (their history is keyed by [Migration.id]); never
/// reorder past migrations relative to ones already released.

@ProviderFor(migrations)
final migrationsProvider = MigrationsProvider._();

/// Ordered registry of data migrations run at startup.
///
/// Append new migrations here, in the order they must run. Keep entries
/// forever once shipped (their history is keyed by [Migration.id]); never
/// reorder past migrations relative to ones already released.

final class MigrationsProvider
    extends
        $FunctionalProvider<List<Migration>, List<Migration>, List<Migration>>
    with $Provider<List<Migration>> {
  /// Ordered registry of data migrations run at startup.
  ///
  /// Append new migrations here, in the order they must run. Keep entries
  /// forever once shipped (their history is keyed by [Migration.id]); never
  /// reorder past migrations relative to ones already released.
  MigrationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'migrationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$migrationsHash();

  @$internal
  @override
  $ProviderElement<List<Migration>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Migration> create(Ref ref) {
    return migrations(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Migration> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Migration>>(value),
    );
  }
}

String _$migrationsHash() => r'17fdb00008fa2f18caa6289b4f6f117fa1f27ba3';
