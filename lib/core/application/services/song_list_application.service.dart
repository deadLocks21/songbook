import 'package:songbook/core/application/usecases/delete_song_list.usecase.dart';
import 'package:songbook/core/application/usecases/get_all_song_lists.usecase.dart';
import 'package:songbook/core/application/usecases/get_song_list_detail.usecase.dart';
import 'package:songbook/core/application/usecases/save_song_list.usecase.dart';

/// Service applicatif pour les listes de chants.
/// Regroupe tous les cas d'usage lies aux listes.
class SongListApplicationService {
  final GetAllSongListsUseCase getAllSongLists;
  final GetSongListDetailUseCase getSongListDetail;
  final SaveSongListUseCase saveSongList;
  final DeleteSongListUseCase deleteSongList;

  const SongListApplicationService({
    required this.getAllSongLists,
    required this.getSongListDetail,
    required this.saveSongList,
    required this.deleteSongList,
  });
}
