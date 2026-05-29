import 'package:songbook/core/application/dtos/remote_song.dto.dart';
import 'package:songbook/core/domain/model/remote_song.dart';
import 'package:songbook/core/domain/services/remote_song.repository.dart';

/// Implémentation du RemoteSongRepository en mémoire.
///
/// Reproduit fidèlement le jeu de chants d'exemple servi par l'API
/// (`GET /api/songs/examples`, cf. `songbook-api` GetSongsExamplesController) :
/// mêmes id, code, nom, date, ressources et recueils, pour que le mode démo
/// affiche exactement les mêmes données que le backend.
class InMemoryRemoteSongRepository implements RemoteSongRepository {
  InMemoryRemoteSongRepository();

  @override
  Future<List<RemoteSong>> fetchSongs(
    String baseUrl, {
    List<String> recueils = const [],
  }) async {
    const jsonList = [
      {
        'id': '550e8400-e29b-41d4-a716-446655440001',
        'code': 'JN-001',
        'name': 'Amazing Grace',
        'updatedAt': '2024-01-01T00:00:00+00:00',
        'resources': [
          {
            'id': '550e8400-e29b-41d4-a716-446655440101',
            'type': 'image',
            'data': [
              'http://localhost/api/songs/550e8400-e29b-41d4-a716-446655440001/partitions/1/download',
              'http://localhost/api/songs/550e8400-e29b-41d4-a716-446655440001/partitions/2/download',
            ],
          },
        ],
        'recueils': ['REC-001'],
      },
      {
        'id': '550e8400-e29b-41d4-a716-446655440002',
        'code': 'JMS-001',
        'name': 'What a Friend We Have in Jesus',
        'updatedAt': '2024-01-02T00:00:00+00:00',
        'resources': <Map<String, dynamic>>[],
        'recueils': ['REC-001'],
      },
      {
        'id': '550e8400-e29b-41d4-a716-446655440003',
        'code': 'DF-001',
        'name': 'Be Thou My Vision',
        'updatedAt': '2024-01-03T00:00:00+00:00',
        'resources': <Map<String, dynamic>>[],
        'recueils': <String>[],
      },
    ];
    return jsonList
        .map(
          (json) =>
              RemoteSongDto.fromJson(json as Map<String, dynamic>).toDomain(),
        )
        .toList();
  }
}
