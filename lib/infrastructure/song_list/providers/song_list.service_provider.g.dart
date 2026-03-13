// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_list.service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider pour le service applicatif des listes de chants.

@ProviderFor(songListService)
final songListServiceProvider = SongListServiceProvider._();

/// Provider pour le service applicatif des listes de chants.

final class SongListServiceProvider
    extends
        $FunctionalProvider<
          SongListApplicationService,
          SongListApplicationService,
          SongListApplicationService
        >
    with $Provider<SongListApplicationService> {
  /// Provider pour le service applicatif des listes de chants.
  SongListServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'songListServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$songListServiceHash();

  @$internal
  @override
  $ProviderElement<SongListApplicationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SongListApplicationService create(Ref ref) {
    return songListService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SongListApplicationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SongListApplicationService>(value),
    );
  }
}

String _$songListServiceHash() => r'6bbb15ac2af0941d35a4807f835d44b4db9115df';

/// Provider pour recuperer toutes les listes de chants.

@ProviderFor(songLists)
final songListsProvider = SongListsProvider._();

/// Provider pour recuperer toutes les listes de chants.

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
  /// Provider pour recuperer toutes les listes de chants.
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

String _$songListsHash() => r'a2cae7e9ecc7d05a416aa453df2f45712e3200dc';
