// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_list.repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider pour l'implementation du SongListRepository.
/// Utilise InMemorySongListRepository sur le web, DriftSongListRepository sinon.

@ProviderFor(songListRepository)
final songListRepositoryProvider = SongListRepositoryProvider._();

/// Provider pour l'implementation du SongListRepository.
/// Utilise InMemorySongListRepository sur le web, DriftSongListRepository sinon.

final class SongListRepositoryProvider
    extends
        $FunctionalProvider<
          SongListRepository,
          SongListRepository,
          SongListRepository
        >
    with $Provider<SongListRepository> {
  /// Provider pour l'implementation du SongListRepository.
  /// Utilise InMemorySongListRepository sur le web, DriftSongListRepository sinon.
  SongListRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'songListRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$songListRepositoryHash();

  @$internal
  @override
  $ProviderElement<SongListRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SongListRepository create(Ref ref) {
    return songListRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SongListRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SongListRepository>(value),
    );
  }
}

String _$songListRepositoryHash() =>
    r'1a47db6d5ab74711a9ac52ace448754436314ef0';
