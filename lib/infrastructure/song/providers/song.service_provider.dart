import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/application/dtos/song.dto.dart';
import 'package:songbook/core/application/services/song_application.service.dart';
import 'package:songbook/core/application/usecases/get_all_songs.usecase.dart';
import 'package:songbook/infrastructure/song/providers/song.repository_provider.dart';

part 'song.service_provider.g.dart';

/// Provider pour le service applicatif des chants.
/// Assemble tous les usecases liés aux chants.
@riverpod
SongApplicationService songService(Ref ref) {
  final repository = ref.watch(songRepositoryProvider);

  return SongApplicationService(getAllSongs: GetAllSongsUseCase(repository));
}

/// Provider pour récupérer tous les chants.
/// Utilise le service applicatif pour orchestrer le cas d'usage.
@riverpod
Future<List<SongDto>> songs(Ref ref) async {
  final service = ref.watch(songServiceProvider);
  return service.getAllSongs.execute();
}
