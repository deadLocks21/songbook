// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song.service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider pour le service applicatif des chants.
/// Assemble tous les usecases liés aux chants.

@ProviderFor(songService)
final songServiceProvider = SongServiceProvider._();

/// Provider pour le service applicatif des chants.
/// Assemble tous les usecases liés aux chants.

final class SongServiceProvider
    extends
        $FunctionalProvider<
          SongApplicationService,
          SongApplicationService,
          SongApplicationService
        >
    with $Provider<SongApplicationService> {
  /// Provider pour le service applicatif des chants.
  /// Assemble tous les usecases liés aux chants.
  SongServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'songServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$songServiceHash();

  @$internal
  @override
  $ProviderElement<SongApplicationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SongApplicationService create(Ref ref) {
    return songService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SongApplicationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SongApplicationService>(value),
    );
  }
}

String _$songServiceHash() => r'a5d8d894041bb94676d43dce4d60f5fb7db97d0f';
