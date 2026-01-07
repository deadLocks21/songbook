// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider pour stocker la requête de recherche actuelle.

@ProviderFor(SearchQuery)
final searchQueryProvider = SearchQueryProvider._();

/// Provider pour stocker la requête de recherche actuelle.
final class SearchQueryProvider extends $NotifierProvider<SearchQuery, String> {
  /// Provider pour stocker la requête de recherche actuelle.
  SearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchQueryHash();

  @$internal
  @override
  SearchQuery create() => SearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$searchQueryHash() => r'790bd96a8a13bb944767c7bf06a5378cfc78a54d';

/// Provider pour stocker la requête de recherche actuelle.

abstract class _$SearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider pour les chants filtrés selon la requête de recherche.
/// Combine les chants et la requête pour retourner uniquement les chants
/// dont le code ou le titre contient la requête (insensible à la casse).

@ProviderFor(filteredSongs)
final filteredSongsProvider = FilteredSongsProvider._();

/// Provider pour les chants filtrés selon la requête de recherche.
/// Combine les chants et la requête pour retourner uniquement les chants
/// dont le code ou le titre contient la requête (insensible à la casse).

final class FilteredSongsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SongDto>>,
          List<SongDto>,
          FutureOr<List<SongDto>>
        >
    with $FutureModifier<List<SongDto>>, $FutureProvider<List<SongDto>> {
  /// Provider pour les chants filtrés selon la requête de recherche.
  /// Combine les chants et la requête pour retourner uniquement les chants
  /// dont le code ou le titre contient la requête (insensible à la casse).
  FilteredSongsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredSongsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredSongsHash();

  @$internal
  @override
  $FutureProviderElement<List<SongDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SongDto>> create(Ref ref) {
    return filteredSongs(ref);
  }
}

String _$filteredSongsHash() => r'6138d62c2c94591c709cfe8a14cd68cb83758ff8';
