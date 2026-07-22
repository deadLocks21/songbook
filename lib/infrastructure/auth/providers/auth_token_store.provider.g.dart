// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_token_store.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Stockage de la session : `SharedPreferences` hors web, en mémoire sur le
/// web (où le stockage persistant n'est pas souhaité).
///
/// `keepAlive` : une seule instance partagée par le service d'auth (écriture)
/// et l'intercepteur Dio (lecture du Bearer), pour que le cache reste cohérent.

@ProviderFor(authTokenStore)
final authTokenStoreProvider = AuthTokenStoreProvider._();

/// Stockage de la session : `SharedPreferences` hors web, en mémoire sur le
/// web (où le stockage persistant n'est pas souhaité).
///
/// `keepAlive` : une seule instance partagée par le service d'auth (écriture)
/// et l'intercepteur Dio (lecture du Bearer), pour que le cache reste cohérent.

final class AuthTokenStoreProvider
    extends $FunctionalProvider<AuthTokenStore, AuthTokenStore, AuthTokenStore>
    with $Provider<AuthTokenStore> {
  /// Stockage de la session : `SharedPreferences` hors web, en mémoire sur le
  /// web (où le stockage persistant n'est pas souhaité).
  ///
  /// `keepAlive` : une seule instance partagée par le service d'auth (écriture)
  /// et l'intercepteur Dio (lecture du Bearer), pour que le cache reste cohérent.
  AuthTokenStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authTokenStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authTokenStoreHash();

  @$internal
  @override
  $ProviderElement<AuthTokenStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthTokenStore create(Ref ref) {
    return authTokenStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthTokenStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthTokenStore>(value),
    );
  }
}

String _$authTokenStoreHash() => r'3cd5449327774bb7506350b341de389c8dc5517f';
