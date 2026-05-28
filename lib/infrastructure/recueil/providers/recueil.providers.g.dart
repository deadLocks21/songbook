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

/// Catalogue complet des chants distants (un seul appel `/api/songs`).
///
/// Mémoïsé : sert de source pour l'appartenance aux recueils, les totaux et les
/// URLs des partitions, sans refaire d'appel réseau à chaque recalcul des
/// statistiques de téléchargement.

@ProviderFor(remoteSongCatalog)
final remoteSongCatalogProvider = RemoteSongCatalogProvider._();

/// Catalogue complet des chants distants (un seul appel `/api/songs`).
///
/// Mémoïsé : sert de source pour l'appartenance aux recueils, les totaux et les
/// URLs des partitions, sans refaire d'appel réseau à chaque recalcul des
/// statistiques de téléchargement.

final class RemoteSongCatalogProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RemoteSong>>,
          List<RemoteSong>,
          FutureOr<List<RemoteSong>>
        >
    with $FutureModifier<List<RemoteSong>>, $FutureProvider<List<RemoteSong>> {
  /// Catalogue complet des chants distants (un seul appel `/api/songs`).
  ///
  /// Mémoïsé : sert de source pour l'appartenance aux recueils, les totaux et les
  /// URLs des partitions, sans refaire d'appel réseau à chaque recalcul des
  /// statistiques de téléchargement.
  RemoteSongCatalogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remoteSongCatalogProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remoteSongCatalogHash();

  @$internal
  @override
  $FutureProviderElement<List<RemoteSong>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RemoteSong>> create(Ref ref) {
    return remoteSongCatalog(ref);
  }
}

String _$remoteSongCatalogHash() => r'16f025a7a2bbb80c9b990a93e57868bc851b9275';

/// Statistiques par code de recueil : total (depuis le catalogue mémoïsé) et
/// nombre de chants déjà téléchargés (présence des partitions sur le disque).
///
/// Seule la partie disque est recalculée ici ; le catalogue réseau étant
/// mémoïsé, invalider ce provider (ex. à l'ouverture des réglages) ne relance
/// que les vérifications de fichiers locaux.

@ProviderFor(recueilSongStats)
final recueilSongStatsProvider = RecueilSongStatsProvider._();

/// Statistiques par code de recueil : total (depuis le catalogue mémoïsé) et
/// nombre de chants déjà téléchargés (présence des partitions sur le disque).
///
/// Seule la partie disque est recalculée ici ; le catalogue réseau étant
/// mémoïsé, invalider ce provider (ex. à l'ouverture des réglages) ne relance
/// que les vérifications de fichiers locaux.

final class RecueilSongStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, RecueilSongStats>>,
          Map<String, RecueilSongStats>,
          FutureOr<Map<String, RecueilSongStats>>
        >
    with
        $FutureModifier<Map<String, RecueilSongStats>>,
        $FutureProvider<Map<String, RecueilSongStats>> {
  /// Statistiques par code de recueil : total (depuis le catalogue mémoïsé) et
  /// nombre de chants déjà téléchargés (présence des partitions sur le disque).
  ///
  /// Seule la partie disque est recalculée ici ; le catalogue réseau étant
  /// mémoïsé, invalider ce provider (ex. à l'ouverture des réglages) ne relance
  /// que les vérifications de fichiers locaux.
  RecueilSongStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recueilSongStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recueilSongStatsHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, RecueilSongStats>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, RecueilSongStats>> create(Ref ref) {
    return recueilSongStats(ref);
  }
}

String _$recueilSongStatsHash() => r'71b5b386e659a758c4987808be85cc734759f23e';
