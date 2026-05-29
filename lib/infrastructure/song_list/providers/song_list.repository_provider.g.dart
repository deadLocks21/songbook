// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_list.repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider pour l'implementation du SongListRepository.
/// En mémoire en mode démo (web, aucune URL, ou URL « memory »),
/// DriftSongListRepository sinon — cf. [inMemoryModeProvider].
///
/// Comme [songRepository], l'implémentation en mémoire conserve son état en
/// instance : on épingle le provider (`ref.keepAlive`) en mode démo pour ne pas
/// le perdre à l'auto-dispose (Drift, lui, persiste sur disque).

@ProviderFor(songListRepository)
final songListRepositoryProvider = SongListRepositoryProvider._();

/// Provider pour l'implementation du SongListRepository.
/// En mémoire en mode démo (web, aucune URL, ou URL « memory »),
/// DriftSongListRepository sinon — cf. [inMemoryModeProvider].
///
/// Comme [songRepository], l'implémentation en mémoire conserve son état en
/// instance : on épingle le provider (`ref.keepAlive`) en mode démo pour ne pas
/// le perdre à l'auto-dispose (Drift, lui, persiste sur disque).

final class SongListRepositoryProvider
    extends
        $FunctionalProvider<
          SongListRepository,
          SongListRepository,
          SongListRepository
        >
    with $Provider<SongListRepository> {
  /// Provider pour l'implementation du SongListRepository.
  /// En mémoire en mode démo (web, aucune URL, ou URL « memory »),
  /// DriftSongListRepository sinon — cf. [inMemoryModeProvider].
  ///
  /// Comme [songRepository], l'implémentation en mémoire conserve son état en
  /// instance : on épingle le provider (`ref.keepAlive`) en mode démo pour ne pas
  /// le perdre à l'auto-dispose (Drift, lui, persiste sur disque).
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
    r'deae504aaebead998a2f0b9197522d95ab0e0bcc';
