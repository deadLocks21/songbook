// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recueil.providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider pour le repository des recueils distants.
/// Utilise l'implémentation en mémoire sur le web (CORS).

@ProviderFor(remoteRecueilRepository)
final remoteRecueilRepositoryProvider = RemoteRecueilRepositoryProvider._();

/// Provider pour le repository des recueils distants.
/// Utilise l'implémentation en mémoire sur le web (CORS).

final class RemoteRecueilRepositoryProvider
    extends
        $FunctionalProvider<
          RemoteRecueilRepository,
          RemoteRecueilRepository,
          RemoteRecueilRepository
        >
    with $Provider<RemoteRecueilRepository> {
  /// Provider pour le repository des recueils distants.
  /// Utilise l'implémentation en mémoire sur le web (CORS).
  RemoteRecueilRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remoteRecueilRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remoteRecueilRepositoryHash();

  @$internal
  @override
  $ProviderElement<RemoteRecueilRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RemoteRecueilRepository create(Ref ref) {
    return remoteRecueilRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RemoteRecueilRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RemoteRecueilRepository>(value),
    );
  }
}

String _$remoteRecueilRepositoryHash() =>
    r'612a7c141dcb0e5e407fd813e0b6697de136c854';

/// Liste des recueils disponibles sur le serveur configuré.
///
/// Nécessite l'authentification (JWT injecté par l'intercepteur Dio) : à
/// n'utiliser qu'après connexion.

@ProviderFor(availableRecueils)
final availableRecueilsProvider = AvailableRecueilsProvider._();

/// Liste des recueils disponibles sur le serveur configuré.
///
/// Nécessite l'authentification (JWT injecté par l'intercepteur Dio) : à
/// n'utiliser qu'après connexion.

final class AvailableRecueilsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Recueil>>,
          List<Recueil>,
          FutureOr<List<Recueil>>
        >
    with $FutureModifier<List<Recueil>>, $FutureProvider<List<Recueil>> {
  /// Liste des recueils disponibles sur le serveur configuré.
  ///
  /// Nécessite l'authentification (JWT injecté par l'intercepteur Dio) : à
  /// n'utiliser qu'après connexion.
  AvailableRecueilsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availableRecueilsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$availableRecueilsHash();

  @$internal
  @override
  $FutureProviderElement<List<Recueil>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Recueil>> create(Ref ref) {
    return availableRecueils(ref);
  }
}

String _$availableRecueilsHash() => r'cd76bee1e27fc24801e1ee0277ceacf3244d107e';

/// Nombre de chants par code de recueil, dérivé du champ `recueils` de chaque
/// chant renvoyé par `/api/songs`.
///
/// L'API `/api/recueils` ne fournit pas ce décompte ; on le calcule donc à
/// partir de la liste complète des chants (un seul appel réseau).

@ProviderFor(recueilSongCounts)
final recueilSongCountsProvider = RecueilSongCountsProvider._();

/// Nombre de chants par code de recueil, dérivé du champ `recueils` de chaque
/// chant renvoyé par `/api/songs`.
///
/// L'API `/api/recueils` ne fournit pas ce décompte ; on le calcule donc à
/// partir de la liste complète des chants (un seul appel réseau).

final class RecueilSongCountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, int>>,
          Map<String, int>,
          FutureOr<Map<String, int>>
        >
    with $FutureModifier<Map<String, int>>, $FutureProvider<Map<String, int>> {
  /// Nombre de chants par code de recueil, dérivé du champ `recueils` de chaque
  /// chant renvoyé par `/api/songs`.
  ///
  /// L'API `/api/recueils` ne fournit pas ce décompte ; on le calcule donc à
  /// partir de la liste complète des chants (un seul appel réseau).
  RecueilSongCountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recueilSongCountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recueilSongCountsHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, int>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, int>> create(Ref ref) {
    return recueilSongCounts(ref);
  }
}

String _$recueilSongCountsHash() => r'2f52ec18dc38ee7c4f244aa58f2a4a6c244bd708';
