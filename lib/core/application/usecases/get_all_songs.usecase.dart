import 'package:songbook/core/application/dtos/song.dto.dart';
import 'package:songbook/core/domain/services/song.repository.dart';

/// Cas d'usage pour récupérer tous les chants.
/// Transforme les entités domain en DTOs pour l'UI.
class GetAllSongsUseCase {
  final SongRepository repository;

  const GetAllSongsUseCase(this.repository);

  /// Exécute le cas d'usage et retourne tous les chants sous forme de DTOs.
  Future<List<SongDto>> execute() async {
    final songs = await repository.getAllSongs();
    return songs.map(SongDto.fromDomain).toList();
  }
}
