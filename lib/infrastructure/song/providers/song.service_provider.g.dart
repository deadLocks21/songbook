// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(songCatalogService)
final songCatalogServiceProvider = SongCatalogServiceProvider._();

final class SongCatalogServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<SongCatalogService>,
          SongCatalogService,
          FutureOr<SongCatalogService>
        >
    with
        $FutureModifier<SongCatalogService>,
        $FutureProvider<SongCatalogService> {
  SongCatalogServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'songCatalogServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$songCatalogServiceHash();

  @$internal
  @override
  $FutureProviderElement<SongCatalogService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SongCatalogService> create(Ref ref) {
    return songCatalogService(ref);
  }
}

String _$songCatalogServiceHash() =>
    r'43f4643ce1406b1ce7badfbd42ac6d1e713220af';

@ProviderFor(songs)
final songsProvider = SongsProvider._();

final class SongsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SongDto>>,
          List<SongDto>,
          FutureOr<List<SongDto>>
        >
    with $FutureModifier<List<SongDto>>, $FutureProvider<List<SongDto>> {
  SongsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'songsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$songsHash();

  @$internal
  @override
  $FutureProviderElement<List<SongDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SongDto>> create(Ref ref) {
    return songs(ref);
  }
}

String _$songsHash() => r'5f2f876b755093a865178e7b2eb23b3da6763735';
