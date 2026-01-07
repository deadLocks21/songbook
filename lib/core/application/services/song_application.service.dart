import 'package:songbook/core/application/usecases/get_all_songs.usecase.dart';

/// Service applicatif pour les chants.
/// Regroupe tous les cas d'usage liés aux chants.
class SongApplicationService {
  final GetAllSongsUseCase getAllSongs;

  const SongApplicationService({required this.getAllSongs});
}
