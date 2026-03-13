// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider pour l'implémentation du SongRepository.
/// Utilise InMemorySongRepository sur le web, DriftSongRepository sinon.

@ProviderFor(songRepository)
final songRepositoryProvider = SongRepositoryProvider._();

/// Provider pour l'implémentation du SongRepository.
/// Utilise InMemorySongRepository sur le web, DriftSongRepository sinon.

final class SongRepositoryProvider
    extends $FunctionalProvider<SongRepository, SongRepository, SongRepository>
    with $Provider<SongRepository> {
  /// Provider pour l'implémentation du SongRepository.
  /// Utilise InMemorySongRepository sur le web, DriftSongRepository sinon.
  SongRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'songRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$songRepositoryHash();

  @$internal
  @override
  $ProviderElement<SongRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SongRepository create(Ref ref) {
    return songRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SongRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SongRepository>(value),
    );
  }
}

String _$songRepositoryHash() => r'b02592b96a9822e623c250407b567cf62b764642';
