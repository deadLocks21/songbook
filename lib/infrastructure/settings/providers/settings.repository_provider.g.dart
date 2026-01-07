// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider pour l'implémentation du repository de paramètres

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

/// Provider pour l'implémentation du repository de paramètres

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          SharedPreferencesSettingsRepository,
          SharedPreferencesSettingsRepository,
          SharedPreferencesSettingsRepository
        >
    with $Provider<SharedPreferencesSettingsRepository> {
  /// Provider pour l'implémentation du repository de paramètres
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SharedPreferencesSettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SharedPreferencesSettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferencesSettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferencesSettingsRepository>(
        value,
      ),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'4490161265f0c290b197a8eab54d144bf8b9a691';
