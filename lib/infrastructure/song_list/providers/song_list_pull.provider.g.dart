// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_list_pull.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(songListPullService)
final songListPullServiceProvider = SongListPullServiceProvider._();

final class SongListPullServiceProvider
    extends
        $FunctionalProvider<
          SongListPullService,
          SongListPullService,
          SongListPullService
        >
    with $Provider<SongListPullService> {
  SongListPullServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'songListPullServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$songListPullServiceHash();

  @$internal
  @override
  $ProviderElement<SongListPullService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SongListPullService create(Ref ref) {
    return songListPullService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SongListPullService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SongListPullService>(value),
    );
  }
}

String _$songListPullServiceHash() =>
    r'9e68f3f22723a8735233687890355a8d15a27f4c';

/// Pilote le tirage depuis l'UI : résout l'URL du backend, appelle le service,
/// puis pousse et rafraîchit ce qui doit l'être.
///
/// L'état est `true` pendant un appel réseau.

@ProviderFor(SongListPullNotifier)
final songListPullProvider = SongListPullNotifierProvider._();

/// Pilote le tirage depuis l'UI : résout l'URL du backend, appelle le service,
/// puis pousse et rafraîchit ce qui doit l'être.
///
/// L'état est `true` pendant un appel réseau.
final class SongListPullNotifierProvider
    extends $NotifierProvider<SongListPullNotifier, bool> {
  /// Pilote le tirage depuis l'UI : résout l'URL du backend, appelle le service,
  /// puis pousse et rafraîchit ce qui doit l'être.
  ///
  /// L'état est `true` pendant un appel réseau.
  SongListPullNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'songListPullProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$songListPullNotifierHash();

  @$internal
  @override
  SongListPullNotifier create() => SongListPullNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$songListPullNotifierHash() =>
    r'90b380e043bc091266afb9df1be05ab25b8a6bfe';

/// Pilote le tirage depuis l'UI : résout l'URL du backend, appelle le service,
/// puis pousse et rafraîchit ce qui doit l'être.
///
/// L'état est `true` pendant un appel réseau.

abstract class _$SongListPullNotifier extends $Notifier<bool> {
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
