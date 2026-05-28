// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fournit l'implémentation du repository d'authentification.
///
/// Vrais appels HTTP hors web ; en mémoire sur le web (CORS), comme pour le
/// repository des chants distants.

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// Fournit l'implémentation du repository d'authentification.
///
/// Vrais appels HTTP hors web ; en mémoire sur le web (CORS), comme pour le
/// repository des chants distants.

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// Fournit l'implémentation du repository d'authentification.
  ///
  /// Vrais appels HTTP hors web ; en mémoire sur le web (CORS), comme pour le
  /// repository des chants distants.
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

String _$authRepositoryHash() => r'd85a0d3c926fdf2a49c7c43557fdfe2bf346a0b6';
