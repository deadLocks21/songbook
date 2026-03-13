// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme.repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider pour l'implémentation du repository de thème.
/// Utilise InMemoryThemeRepository sur le web, SharedPreferencesThemeRepository sinon.

@ProviderFor(themeRepository)
final themeRepositoryProvider = ThemeRepositoryProvider._();

/// Provider pour l'implémentation du repository de thème.
/// Utilise InMemoryThemeRepository sur le web, SharedPreferencesThemeRepository sinon.

final class ThemeRepositoryProvider
    extends
        $FunctionalProvider<ThemeRepository, ThemeRepository, ThemeRepository>
    with $Provider<ThemeRepository> {
  /// Provider pour l'implémentation du repository de thème.
  /// Utilise InMemoryThemeRepository sur le web, SharedPreferencesThemeRepository sinon.
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
  $ProviderElement<ThemeRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ThemeRepository create(Ref ref) {
    return themeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeRepository>(value),
    );
  }
}

String _$themeRepositoryHash() => r'26d16dcc6b8209d2cd8b2e121482049a6d9c2627';
