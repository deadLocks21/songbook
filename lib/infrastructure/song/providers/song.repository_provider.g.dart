// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider pour l'implémentation du SongRepository.
/// En mémoire en mode démo (web, aucune URL, ou URL « memory »),
/// DriftSongRepository sinon — cf. [inMemoryModeProvider].
///
/// En mode démo, [InMemorySongRepository] garde les chants dans un champ
/// d'instance : on **épingle** alors le provider (`ref.keepAlive`) pour que
/// l'auto-dispose ne recrée pas une instance vide entre la synchro et l'accueil
/// (sinon : chants perdus « count=0 » et re-synchros en boucle). Drift persiste
/// sur disque, donc seul l'in-memory a besoin de cette épingle.

@ProviderFor(songRepository)
final songRepositoryProvider = SongRepositoryProvider._();

/// Provider pour l'implémentation du SongRepository.
/// En mémoire en mode démo (web, aucune URL, ou URL « memory »),
/// DriftSongRepository sinon — cf. [inMemoryModeProvider].
///
/// En mode démo, [InMemorySongRepository] garde les chants dans un champ
/// d'instance : on **épingle** alors le provider (`ref.keepAlive`) pour que
/// l'auto-dispose ne recrée pas une instance vide entre la synchro et l'accueil
/// (sinon : chants perdus « count=0 » et re-synchros en boucle). Drift persiste
/// sur disque, donc seul l'in-memory a besoin de cette épingle.

final class SongRepositoryProvider
    extends $FunctionalProvider<SongRepository, SongRepository, SongRepository>
    with $Provider<SongRepository> {
  /// Provider pour l'implémentation du SongRepository.
  /// En mémoire en mode démo (web, aucune URL, ou URL « memory »),
  /// DriftSongRepository sinon — cf. [inMemoryModeProvider].
  ///
  /// En mode démo, [InMemorySongRepository] garde les chants dans un champ
  /// d'instance : on **épingle** alors le provider (`ref.keepAlive`) pour que
  /// l'auto-dispose ne recrée pas une instance vide entre la synchro et l'accueil
  /// (sinon : chants perdus « count=0 » et re-synchros en boucle). Drift persiste
  /// sur disque, donc seul l'in-memory a besoin de cette épingle.
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

String _$songRepositoryHash() => r'88aa12a20068c38a020970ef14efcc9b1073e3a8';
