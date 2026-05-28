// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync.providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider pour l'instance Dio utilisée pour les requêtes HTTP.

@ProviderFor(dio)
final dioProvider = DioProvider._();

/// Provider pour l'instance Dio utilisée pour les requêtes HTTP.

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Provider pour l'instance Dio utilisée pour les requêtes HTTP.
  DioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'fe06476ea1a7dfddbc28a8a154d81ec69066e317';

/// Provider pour le repository des songs distants.
/// Utilise InMemoryRemoteSongRepository sur le web (CORS empêche les appels Dio directs).

@ProviderFor(remoteSongRepository)
final remoteSongRepositoryProvider = RemoteSongRepositoryProvider._();

/// Provider pour le repository des songs distants.
/// Utilise InMemoryRemoteSongRepository sur le web (CORS empêche les appels Dio directs).

final class RemoteSongRepositoryProvider
    extends
        $FunctionalProvider<
          RemoteSongRepository,
          RemoteSongRepository,
          RemoteSongRepository
        >
    with $Provider<RemoteSongRepository> {
  /// Provider pour le repository des songs distants.
  /// Utilise InMemoryRemoteSongRepository sur le web (CORS empêche les appels Dio directs).
  RemoteSongRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remoteSongRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remoteSongRepositoryHash();

  @$internal
  @override
  $ProviderElement<RemoteSongRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RemoteSongRepository create(Ref ref) {
    return remoteSongRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RemoteSongRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RemoteSongRepository>(value),
    );
  }
}

String _$remoteSongRepositoryHash() =>
    r'fec5963f9ce7dc008262f642d1f7d14c39276f75';

/// Provider pour le cache des ressources (images/PDF).
/// Utilise InMemoryResourceCacheRepository sur le web.
/// Retourne un Future car nécessite le chemin du répertoire de l'application (hors web).

@ProviderFor(resourceCacheRepository)
final resourceCacheRepositoryProvider = ResourceCacheRepositoryProvider._();

/// Provider pour le cache des ressources (images/PDF).
/// Utilise InMemoryResourceCacheRepository sur le web.
/// Retourne un Future car nécessite le chemin du répertoire de l'application (hors web).

final class ResourceCacheRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<ResourceCacheRepository>,
          ResourceCacheRepository,
          FutureOr<ResourceCacheRepository>
        >
    with
        $FutureModifier<ResourceCacheRepository>,
        $FutureProvider<ResourceCacheRepository> {
  /// Provider pour le cache des ressources (images/PDF).
  /// Utilise InMemoryResourceCacheRepository sur le web.
  /// Retourne un Future car nécessite le chemin du répertoire de l'application (hors web).
  ResourceCacheRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'resourceCacheRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resourceCacheRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<ResourceCacheRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ResourceCacheRepository> create(Ref ref) {
    return resourceCacheRepository(ref);
  }
}

String _$resourceCacheRepositoryHash() =>
    r'53e808121f1a5d00adc2521496457fcc15524990';

/// Provider pour le service de synchronisation.

@ProviderFor(syncService)
final syncServiceProvider = SyncServiceProvider._();

/// Provider pour le service de synchronisation.

final class SyncServiceProvider
    extends $FunctionalProvider<SyncService, SyncService, SyncService>
    with $Provider<SyncService> {
  /// Provider pour le service de synchronisation.
  SyncServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncServiceHash();

  @$internal
  @override
  $ProviderElement<SyncService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SyncService create(Ref ref) {
    return syncService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncService>(value),
    );
  }
}

String _$syncServiceHash() => r'b33d2e64c96ade347b0cbff5125245cd8f419817';
