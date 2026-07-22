// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_list.service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(setlistService)
final setlistServiceProvider = SetlistServiceProvider._();

final class SetlistServiceProvider
    extends $FunctionalProvider<SetlistService, SetlistService, SetlistService>
    with $Provider<SetlistService> {
  SetlistServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setlistServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setlistServiceHash();

  @$internal
  @override
  $ProviderElement<SetlistService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SetlistService create(Ref ref) {
    return setlistService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SetlistService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SetlistService>(value),
    );
  }
}

String _$setlistServiceHash() => r'cd133c2088d91537e8d30b3ba669dcd630471cad';

@ProviderFor(songLists)
final songListsProvider = SongListsProvider._();

final class SongListsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SongListDto>>,
          List<SongListDto>,
          FutureOr<List<SongListDto>>
        >
    with
        $FutureModifier<List<SongListDto>>,
        $FutureProvider<List<SongListDto>> {
  SongListsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'songListsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$songListsHash();

  @$internal
  @override
  $FutureProviderElement<List<SongListDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SongListDto>> create(Ref ref) {
    return songLists(ref);
  }
}

String _$songListsHash() => r'5e748aac4604ef6476a0f1eee58a64e2b256aebd';
