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

String _$dioHash() => r'831fb3837c329739dd14ae421d4633397223c156';

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

/// Provider pour le repository des ressources distantes.
/// Utilise InMemoryRemoteResourceRepository sur le web.
/// Retourne un Future car nécessite le chemin du répertoire de l'application (hors web).
/// Utilise le répertoire de synchronisation personnalisé s'il est configuré.

@ProviderFor(remoteResourceRepository)
final remoteResourceRepositoryProvider = RemoteResourceRepositoryProvider._();

/// Provider pour le repository des ressources distantes.
/// Utilise InMemoryRemoteResourceRepository sur le web.
/// Retourne un Future car nécessite le chemin du répertoire de l'application (hors web).
/// Utilise le répertoire de synchronisation personnalisé s'il est configuré.

final class RemoteResourceRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<RemoteResourceRepository>,
          RemoteResourceRepository,
          FutureOr<RemoteResourceRepository>
        >
    with
        $FutureModifier<RemoteResourceRepository>,
        $FutureProvider<RemoteResourceRepository> {
  /// Provider pour le repository des ressources distantes.
  /// Utilise InMemoryRemoteResourceRepository sur le web.
  /// Retourne un Future car nécessite le chemin du répertoire de l'application (hors web).
  /// Utilise le répertoire de synchronisation personnalisé s'il est configuré.
  RemoteResourceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remoteResourceRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remoteResourceRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<RemoteResourceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RemoteResourceRepository> create(Ref ref) {
    return remoteResourceRepository(ref);
  }
}

String _$remoteResourceRepositoryHash() =>
    r'b1eec9f98bfd6b1dbe1e7d311a4f103cb6b79e8a';

/// Provider pour le service de synchronisation.

@ProviderFor(syncService)
final syncServiceProvider = SyncServiceProvider._();

/// Provider pour le service de synchronisation.

final class SyncServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<SyncService>,
          SyncService,
          FutureOr<SyncService>
        >
    with $FutureModifier<SyncService>, $FutureProvider<SyncService> {
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
  $FutureProviderElement<SyncService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SyncService> create(Ref ref) {
    return syncService(ref);
  }
}

String _$syncServiceHash() => r'988bfc7d5a1648cb7ab3c484ddaa03c977db643f';
