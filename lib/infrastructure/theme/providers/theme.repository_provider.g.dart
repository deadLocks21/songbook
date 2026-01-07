// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme.repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider pour l'implémentation du repository de thème

@ProviderFor(themeRepository)
final themeRepositoryProvider = ThemeRepositoryProvider._();

/// Provider pour l'implémentation du repository de thème

final class ThemeRepositoryProvider
    extends
        $FunctionalProvider<
          SharedPreferencesThemeRepository,
          SharedPreferencesThemeRepository,
          SharedPreferencesThemeRepository
        >
    with $Provider<SharedPreferencesThemeRepository> {
  /// Provider pour l'implémentation du repository de thème
  ThemeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeRepositoryHash();

  @$internal
  @override
  $ProviderElement<SharedPreferencesThemeRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SharedPreferencesThemeRepository create(Ref ref) {
    return themeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferencesThemeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferencesThemeRepository>(
        value,
      ),
    );
  }
}

String _$themeRepositoryHash() => r'2629d5fee626f8171d8a9f229f60b3159efe0196';
