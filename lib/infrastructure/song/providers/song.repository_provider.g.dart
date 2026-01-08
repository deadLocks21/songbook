// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider pour l'implémentation du SongRepository.
/// En développement/debug: utilise InMemorySongRepository avec données d'exemple.
/// En production: utilise DriftSongRepository avec la base de données SQLite.

@ProviderFor(songRepository)
final songRepositoryProvider = SongRepositoryProvider._();

/// Provider pour l'implémentation du SongRepository.
/// En développement/debug: utilise InMemorySongRepository avec données d'exemple.
/// En production: utilise DriftSongRepository avec la base de données SQLite.

final class SongRepositoryProvider
    extends $FunctionalProvider<SongRepository, SongRepository, SongRepository>
    with $Provider<SongRepository> {
  /// Provider pour l'implémentation du SongRepository.
  /// En développement/debug: utilise InMemorySongRepository avec données d'exemple.
  /// En production: utilise DriftSongRepository avec la base de données SQLite.
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

String _$songRepositoryHash() => r'11e6c0ef77dba72b1bd33152e8ed1d4a5268f447';
