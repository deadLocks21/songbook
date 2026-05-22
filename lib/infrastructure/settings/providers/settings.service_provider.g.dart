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
    r'497eb2fe60209e9626d203485c413f17de51a31b';

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

@ProviderFor(SyncDirectoryNotifier)
final syncDirectoryProvider = SyncDirectoryNotifierProvider._();

final class SyncDirectoryNotifierProvider
    extends $AsyncNotifierProvider<SyncDirectoryNotifier, String?> {
  SyncDirectoryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncDirectoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncDirectoryNotifierHash();

  @$internal
  @override
  SyncDirectoryNotifier create() => SyncDirectoryNotifier();
}

String _$syncDirectoryNotifierHash() =>
    r'ea1d62486780fba77447deb8c95ca82c04dfe323';

abstract class _$SyncDirectoryNotifier extends $AsyncNotifier<String?> {
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

String _$themeModeNotifierHash() => r'2bd6faf40bb59cc1282871ca64e46d0693768a1b';

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
