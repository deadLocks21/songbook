import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/application/dtos/song.dto.dart';
import 'package:songbook/infrastructure/song/providers/song.service_provider.dart';

part 'search_provider.g.dart';

/// Provider pour stocker la requête de recherche actuelle.
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  /// Met à jour la requête de recherche.
  void update(String query) => state = query;

  /// Efface la requête de recherche.
  void clear() => state = '';
}

/// Provider pour les chants filtrés selon la requête de recherche.
/// Combine les chants et la requête pour retourner uniquement les chants
/// dont le code ou le titre contient la requête (insensible à la casse).
@riverpod
Future<List<SongDto>> filteredSongs(Ref ref) async {
  final songs = await ref.watch(songsProvider.future);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  if (query.isEmpty) {
    return songs;
  }

  return songs.where((song) {
    final code = song.code.toLowerCase();
    final name = song.name.toLowerCase();
    return code.contains(query) || name.contains(query);
  }).toList();
}
