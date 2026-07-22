// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_list_sharing.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(songListSharingService)
final songListSharingServiceProvider = SongListSharingServiceProvider._();

final class SongListSharingServiceProvider
    extends
        $FunctionalProvider<
          SongListSharingService,
          SongListSharingService,
          SongListSharingService
        >
    with $Provider<SongListSharingService> {
  SongListSharingServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'songListSharingServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$songListSharingServiceHash();

  @$internal
  @override
  $ProviderElement<SongListSharingService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SongListSharingService create(Ref ref) {
    return songListSharingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SongListSharingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SongListSharingService>(value),
    );
  }
}

String _$songListSharingServiceHash() =>
    r'1d4c7815026fb2dee047b45e63f73f66f1e005b0';

/// Pilote le partage et l'abonnement depuis l'UI : résout l'URL du backend,
/// appelle le serveur, et rafraîchit les listes.
///
/// L'état est `true` pendant un appel réseau, pour que l'écran puisse
/// désactiver son bouton.
///
/// `keepAlive` pour la même raison que la synchro : une duplication déclenchée
/// depuis une boîte de dialogue doit survivre à sa fermeture.

@ProviderFor(SongListSharingNotifier)
final songListSharingProvider = SongListSharingNotifierProvider._();

/// Pilote le partage et l'abonnement depuis l'UI : résout l'URL du backend,
/// appelle le serveur, et rafraîchit les listes.
///
/// L'état est `true` pendant un appel réseau, pour que l'écran puisse
/// désactiver son bouton.
///
/// `keepAlive` pour la même raison que la synchro : une duplication déclenchée
/// depuis une boîte de dialogue doit survivre à sa fermeture.
final class SongListSharingNotifierProvider
    extends $NotifierProvider<SongListSharingNotifier, bool> {
  /// Pilote le partage et l'abonnement depuis l'UI : résout l'URL du backend,
  /// appelle le serveur, et rafraîchit les listes.
  ///
  /// L'état est `true` pendant un appel réseau, pour que l'écran puisse
  /// désactiver son bouton.
  ///
  /// `keepAlive` pour la même raison que la synchro : une duplication déclenchée
  /// depuis une boîte de dialogue doit survivre à sa fermeture.
  SongListSharingNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'songListSharingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$songListSharingNotifierHash();

  @$internal
  @override
  SongListSharingNotifier create() => SongListSharingNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$songListSharingNotifierHash() =>
    r'ceaf52ebeb99b49f40d6042adeda2bbc38a46dc6';

/// Pilote le partage et l'abonnement depuis l'UI : résout l'URL du backend,
/// appelle le serveur, et rafraîchit les listes.
///
/// L'état est `true` pendant un appel réseau, pour que l'écran puisse
/// désactiver son bouton.
///
/// `keepAlive` pour la même raison que la synchro : une duplication déclenchée
/// depuis une boîte de dialogue doit survivre à sa fermeture.

abstract class _$SongListSharingNotifier extends $Notifier<bool> {
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
