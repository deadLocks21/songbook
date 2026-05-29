// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fournit l'implémentation du repository d'authentification.
///
/// Vrais appels HTTP quand un backend réel est configuré ; en mémoire sinon
/// (web, aucune URL, ou URL « memory ») — cf. [inMemoryModeProvider].

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// Fournit l'implémentation du repository d'authentification.
///
/// Vrais appels HTTP quand un backend réel est configuré ; en mémoire sinon
/// (web, aucune URL, ou URL « memory ») — cf. [inMemoryModeProvider].

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// Fournit l'implémentation du repository d'authentification.
  ///
  /// Vrais appels HTTP quand un backend réel est configuré ; en mémoire sinon
  /// (web, aucune URL, ou URL « memory ») — cf. [inMemoryModeProvider].
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'abe313f4b65846bc1b789d3054143ebaf3b51c7b';
