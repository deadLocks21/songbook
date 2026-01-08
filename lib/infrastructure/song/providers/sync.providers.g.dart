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

String _$dioHash() => r'a03da399b44b3740dc4fcfc6716203041d66ff01';

/// Provider pour le repository des songs distants.

@ProviderFor(remoteSongRepository)
final remoteSongRepositoryProvider = RemoteSongRepositoryProvider._();

/// Provider pour le repository des songs distants.

final class RemoteSongRepositoryProvider
    extends
        $FunctionalProvider<
          RemoteSongRepository,
          RemoteSongRepository,
          RemoteSongRepository
        >
    with $Provider<RemoteSongRepository> {
  /// Provider pour le repository des songs distants.
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
    r'6b4b4a9c5a46a70e941f67c041e16dc2d39940bd';

/// Provider pour le repository des ressources distantes.
/// Retourne un Future car nécessite le chemin du répertoire de l'application.

@ProviderFor(remoteResourceRepository)
final remoteResourceRepositoryProvider = RemoteResourceRepositoryProvider._();

/// Provider pour le repository des ressources distantes.
/// Retourne un Future car nécessite le chemin du répertoire de l'application.

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
  /// Retourne un Future car nécessite le chemin du répertoire de l'application.
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
    r'2da5055f31d0e73b639497b2b98750c5afa0d86f';

/// Provider pour le use case de calcul des différences de synchronisation.

@ProviderFor(computeSyncDiffUseCase)
final computeSyncDiffUseCaseProvider = ComputeSyncDiffUseCaseProvider._();

/// Provider pour le use case de calcul des différences de synchronisation.

final class ComputeSyncDiffUseCaseProvider
    extends
        $FunctionalProvider<
          ComputeSyncDiffUseCase,
          ComputeSyncDiffUseCase,
          ComputeSyncDiffUseCase
        >
    with $Provider<ComputeSyncDiffUseCase> {
  /// Provider pour le use case de calcul des différences de synchronisation.
  ComputeSyncDiffUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'computeSyncDiffUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$computeSyncDiffUseCaseHash();

  @$internal
  @override
  $ProviderElement<ComputeSyncDiffUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ComputeSyncDiffUseCase create(Ref ref) {
    return computeSyncDiffUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ComputeSyncDiffUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ComputeSyncDiffUseCase>(value),
    );
  }
}

String _$computeSyncDiffUseCaseHash() =>
    r'207a890f986d5bee8c9fa3d0fadfb85a8e0072e5';

/// Provider pour le use case d'exécution de la synchronisation.
/// Retourne un Future car dépend du RemoteResourceRepository async.

@ProviderFor(executeSyncUseCase)
final executeSyncUseCaseProvider = ExecuteSyncUseCaseProvider._();

/// Provider pour le use case d'exécution de la synchronisation.
/// Retourne un Future car dépend du RemoteResourceRepository async.

final class ExecuteSyncUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<ExecuteSyncUseCase>,
          ExecuteSyncUseCase,
          FutureOr<ExecuteSyncUseCase>
        >
    with
        $FutureModifier<ExecuteSyncUseCase>,
        $FutureProvider<ExecuteSyncUseCase> {
  /// Provider pour le use case d'exécution de la synchronisation.
  /// Retourne un Future car dépend du RemoteResourceRepository async.
  ExecuteSyncUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'executeSyncUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$executeSyncUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<ExecuteSyncUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ExecuteSyncUseCase> create(Ref ref) {
    return executeSyncUseCase(ref);
  }
}

String _$executeSyncUseCaseHash() =>
    r'a6ee808208dd58ff3f16135a5e61daf1cce79ee4';
