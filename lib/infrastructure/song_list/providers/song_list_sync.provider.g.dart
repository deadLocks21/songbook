// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_list_sync.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider pour le repository distant des listes de chants.
/// En mémoire en mode démo (web, aucune URL, ou URL « memory »), appels Dio
/// sinon — cf. [inMemoryModeProvider].
///
/// Comme le repository local en mémoire, la version démo garde son état en
/// instance : on épingle le provider pour ne pas le perdre à l'auto-dispose,
/// sinon chaque synchro repartirait d'un serveur vide et effacerait tout.

@ProviderFor(remoteSongListRepository)
final remoteSongListRepositoryProvider = RemoteSongListRepositoryProvider._();

/// Provider pour le repository distant des listes de chants.
/// En mémoire en mode démo (web, aucune URL, ou URL « memory »), appels Dio
/// sinon — cf. [inMemoryModeProvider].
///
/// Comme le repository local en mémoire, la version démo garde son état en
/// instance : on épingle le provider pour ne pas le perdre à l'auto-dispose,
/// sinon chaque synchro repartirait d'un serveur vide et effacerait tout.

final class RemoteSongListRepositoryProvider
    extends
        $FunctionalProvider<
          RemoteSongListRepository,
          RemoteSongListRepository,
          RemoteSongListRepository
        >
    with $Provider<RemoteSongListRepository> {
  /// Provider pour le repository distant des listes de chants.
  /// En mémoire en mode démo (web, aucune URL, ou URL « memory »), appels Dio
  /// sinon — cf. [inMemoryModeProvider].
  ///
  /// Comme le repository local en mémoire, la version démo garde son état en
  /// instance : on épingle le provider pour ne pas le perdre à l'auto-dispose,
  /// sinon chaque synchro repartirait d'un serveur vide et effacerait tout.
  RemoteSongListRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remoteSongListRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remoteSongListRepositoryHash();

  @$internal
  @override
  $ProviderElement<RemoteSongListRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RemoteSongListRepository create(Ref ref) {
    return remoteSongListRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RemoteSongListRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RemoteSongListRepository>(value),
    );
  }
}

String _$remoteSongListRepositoryHash() =>
    r'57ca0dd307238419aa1a993ce65c1928e235aa2b';

/// Provider pour le service de synchronisation des listes de chants.

@ProviderFor(songListSyncService)
final songListSyncServiceProvider = SongListSyncServiceProvider._();

/// Provider pour le service de synchronisation des listes de chants.

final class SongListSyncServiceProvider
    extends
        $FunctionalProvider<
          SongListSyncService,
          SongListSyncService,
          SongListSyncService
        >
    with $Provider<SongListSyncService> {
  /// Provider pour le service de synchronisation des listes de chants.
  SongListSyncServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'songListSyncServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$songListSyncServiceHash();

  @$internal
  @override
  $ProviderElement<SongListSyncService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SongListSyncService create(Ref ref) {
    return songListSyncService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SongListSyncService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SongListSyncService>(value),
    );
  }
}

String _$songListSyncServiceHash() =>
    r'cc10b86220f597bda32801e3efcc3d8355692d77';

/// Pilote la synchronisation des listes depuis l'UI : résout l'URL du backend,
/// lance la synchro et rafraîchit les écrans concernés.
///
/// L'état est `true` pendant une synchro en cours.
///
/// Aucune méthode ne propage d'exception : les listes vivent d'abord en local,
/// et un serveur injoignable ne doit ni faire échouer un enregistrement ni
/// interrompre le démarrage. Ce qui n'a pas pu être poussé reste marqué comme
/// tel et repartira à la synchro suivante.
///
/// Volontairement `keepAlive` : un push déclenché par un enregistrement survit
/// à la fermeture de l'écran qui l'a lancé. Sous auto-dispose, quitter la page
/// d'édition juste après avoir sauvegardé pourrait interrompre l'envoi.

@ProviderFor(SongListSyncNotifier)
final songListSyncProvider = SongListSyncNotifierProvider._();

/// Pilote la synchronisation des listes depuis l'UI : résout l'URL du backend,
/// lance la synchro et rafraîchit les écrans concernés.
///
/// L'état est `true` pendant une synchro en cours.
///
/// Aucune méthode ne propage d'exception : les listes vivent d'abord en local,
/// et un serveur injoignable ne doit ni faire échouer un enregistrement ni
/// interrompre le démarrage. Ce qui n'a pas pu être poussé reste marqué comme
/// tel et repartira à la synchro suivante.
///
/// Volontairement `keepAlive` : un push déclenché par un enregistrement survit
/// à la fermeture de l'écran qui l'a lancé. Sous auto-dispose, quitter la page
/// d'édition juste après avoir sauvegardé pourrait interrompre l'envoi.
final class SongListSyncNotifierProvider
    extends $NotifierProvider<SongListSyncNotifier, bool> {
  /// Pilote la synchronisation des listes depuis l'UI : résout l'URL du backend,
  /// lance la synchro et rafraîchit les écrans concernés.
  ///
  /// L'état est `true` pendant une synchro en cours.
  ///
  /// Aucune méthode ne propage d'exception : les listes vivent d'abord en local,
  /// et un serveur injoignable ne doit ni faire échouer un enregistrement ni
  /// interrompre le démarrage. Ce qui n'a pas pu être poussé reste marqué comme
  /// tel et repartira à la synchro suivante.
  ///
  /// Volontairement `keepAlive` : un push déclenché par un enregistrement survit
  /// à la fermeture de l'écran qui l'a lancé. Sous auto-dispose, quitter la page
  /// d'édition juste après avoir sauvegardé pourrait interrompre l'envoi.
  SongListSyncNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'songListSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$songListSyncNotifierHash();

  @$internal
  @override
  SongListSyncNotifier create() => SongListSyncNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$songListSyncNotifierHash() =>
    r'1ab02b3aad9f4b85b5f79246d6c8517f70ca470a';

/// Pilote la synchronisation des listes depuis l'UI : résout l'URL du backend,
/// lance la synchro et rafraîchit les écrans concernés.
///
/// L'état est `true` pendant une synchro en cours.
///
/// Aucune méthode ne propage d'exception : les listes vivent d'abord en local,
/// et un serveur injoignable ne doit ni faire échouer un enregistrement ni
/// interrompre le démarrage. Ce qui n'a pas pu être poussé reste marqué comme
/// tel et repartira à la synchro suivante.
///
/// Volontairement `keepAlive` : un push déclenché par un enregistrement survit
/// à la fermeture de l'écran qui l'a lancé. Sous auto-dispose, quitter la page
/// d'édition juste après avoir sauvegardé pourrait interrompre l'envoi.

abstract class _$SongListSyncNotifier extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
