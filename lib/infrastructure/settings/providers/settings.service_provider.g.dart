// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(settingsService)
final settingsServiceProvider = SettingsServiceProvider._();

final class SettingsServiceProvider
    extends
        $FunctionalProvider<SettingsService, SettingsService, SettingsService>
    with $Provider<SettingsService> {
  SettingsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsServiceHash();

  @$internal
  @override
  $ProviderElement<SettingsService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SettingsService create(Ref ref) {
    return settingsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsService>(value),
    );
  }
}

String _$settingsServiceHash() => r'7c741f069d7f38954c74964a3ec34331d87f7133';

@ProviderFor(BackendUrlNotifier)
final backendUrlProvider = BackendUrlNotifierProvider._();

final class BackendUrlNotifierProvider
    extends $AsyncNotifierProvider<BackendUrlNotifier, String?> {
  BackendUrlNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backendUrlProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backendUrlNotifierHash();

  @$internal
  @override
  BackendUrlNotifier create() => BackendUrlNotifier();
}

String _$backendUrlNotifierHash() =>
    r'd27176d0dd5ce0a6eb53a52059d7f2ebd06d4601';

abstract class _$BackendUrlNotifier extends $AsyncNotifier<String?> {
  FutureOr<String?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Codes des recueils sélectionnés pour le cache local des partitions.

@ProviderFor(SelectedRecueilsNotifier)
final selectedRecueilsProvider = SelectedRecueilsNotifierProvider._();

/// Codes des recueils sélectionnés pour le cache local des partitions.
final class SelectedRecueilsNotifierProvider
    extends $AsyncNotifierProvider<SelectedRecueilsNotifier, List<String>> {
  /// Codes des recueils sélectionnés pour le cache local des partitions.
  SelectedRecueilsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedRecueilsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedRecueilsNotifierHash();

  @$internal
  @override
  SelectedRecueilsNotifier create() => SelectedRecueilsNotifier();
}

String _$selectedRecueilsNotifierHash() =>
    r'f7e2f780c04441b3eab409d041ea3d69bda946ec';

/// Codes des recueils sélectionnés pour le cache local des partitions.

abstract class _$SelectedRecueilsNotifier extends $AsyncNotifier<List<String>> {
  FutureOr<List<String>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<String>>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<String>>, List<String>>,
              AsyncValue<List<String>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ThemeModeNotifier)
final themeModeProvider = ThemeModeNotifierProvider._();

final class ThemeModeNotifierProvider
    extends $AsyncNotifierProvider<ThemeModeNotifier, AppThemeMode> {
  ThemeModeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeNotifierHash();

  @$internal
  @override
  ThemeModeNotifier create() => ThemeModeNotifier();
}

String _$themeModeNotifierHash() => r'480f7c26ecdaa2730bc4ba5023c3fe55fcae7ea0';

abstract class _$ThemeModeNotifier extends $AsyncNotifier<AppThemeMode> {
  FutureOr<AppThemeMode> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AppThemeMode>, AppThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppThemeMode>, AppThemeMode>,
              AsyncValue<AppThemeMode>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Ordre de préférence des types de ressources affichées par défaut.

@ProviderFor(ResourceDisplayOrderNotifier)
final resourceDisplayOrderProvider = ResourceDisplayOrderNotifierProvider._();

/// Ordre de préférence des types de ressources affichées par défaut.
final class ResourceDisplayOrderNotifierProvider
    extends
        $AsyncNotifierProvider<
          ResourceDisplayOrderNotifier,
          List<DisplayResourceType>
        > {
  /// Ordre de préférence des types de ressources affichées par défaut.
  ResourceDisplayOrderNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'resourceDisplayOrderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resourceDisplayOrderNotifierHash();

  @$internal
  @override
  ResourceDisplayOrderNotifier create() => ResourceDisplayOrderNotifier();
}

String _$resourceDisplayOrderNotifierHash() =>
    r'a9d6a326470bb9eecf422fccb5f8b9538b12e69c';

/// Ordre de préférence des types de ressources affichées par défaut.

abstract class _$ResourceDisplayOrderNotifier
    extends $AsyncNotifier<List<DisplayResourceType>> {
  FutureOr<List<DisplayResourceType>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<DisplayResourceType>>,
              List<DisplayResourceType>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<DisplayResourceType>>,
                List<DisplayResourceType>
              >,
              AsyncValue<List<DisplayResourceType>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
