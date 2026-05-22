import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/core/application/services/setlist.service.dart';
import 'package:songbook/infrastructure/song/providers/song.repository_provider.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list.repository_provider.dart';

part 'song_list.service_provider.g.dart';

@riverpod
SetlistService setlistService(Ref ref) {
  final songListRepo = ref.watch(songListRepositoryProvider);
  final songRepo = ref.watch(songRepositoryProvider);
  return SetlistService(songListRepo, songRepo);
}

@riverpod
Future<List<SongListDto>> songLists(Ref ref) async {
  final service = ref.watch(setlistServiceProvider);
  return service.getAllSetlists();
}
