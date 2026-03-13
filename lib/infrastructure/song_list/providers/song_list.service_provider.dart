import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/core/application/services/song_list_application.service.dart';
import 'package:songbook/core/application/usecases/delete_song_list.usecase.dart';
import 'package:songbook/core/application/usecases/get_all_song_lists.usecase.dart';
import 'package:songbook/core/application/usecases/get_song_list_detail.usecase.dart';
import 'package:songbook/core/application/usecases/save_song_list.usecase.dart';
import 'package:songbook/infrastructure/song/providers/song.repository_provider.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list.repository_provider.dart';

part 'song_list.service_provider.g.dart';

/// Provider pour le service applicatif des listes de chants.
@riverpod
SongListApplicationService songListService(Ref ref) {
  final songListRepo = ref.watch(songListRepositoryProvider);
  final songRepo = ref.watch(songRepositoryProvider);

  return SongListApplicationService(
    getAllSongLists: GetAllSongListsUseCase(songListRepo, songRepo),
    getSongListDetail: GetSongListDetailUseCase(songListRepo, songRepo),
    saveSongList: SaveSongListUseCase(songListRepo),
    deleteSongList: DeleteSongListUseCase(songListRepo),
  );
}

/// Provider pour recuperer toutes les listes de chants.
@riverpod
Future<List<SongListDto>> songLists(Ref ref) async {
  final service = ref.watch(songListServiceProvider);
  return service.getAllSongLists.execute();
}
