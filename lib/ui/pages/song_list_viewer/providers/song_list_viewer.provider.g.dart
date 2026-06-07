// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_list_viewer.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider qui resout une liste de chants en SongDto complets
/// (avec resources/images) pour la visualisation.

@ProviderFor(songListViewerData)
final songListViewerDataProvider = SongListViewerDataFamily._();

/// Provider qui resout une liste de chants en SongDto complets
/// (avec resources/images) pour la visualisation.

final class SongListViewerDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<SongListViewerData?>,
          SongListViewerData?,
          FutureOr<SongListViewerData?>
        >
    with
        $FutureModifier<SongListViewerData?>,
        $FutureProvider<SongListViewerData?> {
  /// Provider qui resout une liste de chants en SongDto complets
  /// (avec resources/images) pour la visualisation.
  SongListViewerDataProvider._({
    required SongListViewerDataFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'songListViewerDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$songListViewerDataHash();

  @override
  String toString() {
    return r'songListViewerDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SongListViewerData?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SongListViewerData?> create(Ref ref) {
    final argument = this.argument as String;
    return songListViewerData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SongListViewerDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$songListViewerDataHash() =>
    r'16008ac72c18cdfcaa773dcb3848c00fb2bfce3e';

/// Provider qui resout une liste de chants en SongDto complets
/// (avec resources/images) pour la visualisation.

final class SongListViewerDataFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SongListViewerData?>, String> {
  SongListViewerDataFamily._()
    : super(
        retry: null,
        name: r'songListViewerDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider qui resout une liste de chants en SongDto complets
  /// (avec resources/images) pour la visualisation.

  SongListViewerDataProvider call(String songListId) =>
      SongListViewerDataProvider._(argument: songListId, from: this);

  @override
  String toString() => r'songListViewerDataProvider';
}
