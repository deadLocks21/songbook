import 'package:songbook/core/application/dtos/remote_song.dto.dart';
import 'package:songbook/core/domain/model/remote_song.dart';
import 'package:songbook/core/domain/services/remote_song.repository.dart';

/// Implémentation du RemoteSongRepository en mémoire.
class InMemoryRemoteSongRepository implements RemoteSongRepository {
  InMemoryRemoteSongRepository();

  @override
  Future<List<RemoteSong>> fetchSongs(String baseUrl) async {
    const jsonList = [
      {
        'id': '1',
        'code': '123456',
        'name': 'Song 1',
        'updatedAt': '2026-01-08T10:00:00Z',
        'resources': [
          {
            'id': '1',
            'name': 'Resource 1',
            'type': 'image',
            'imageUrls': ['https://example.com/image1.jpg'],
          },
        ],
      },
      {
        'id': '2',
        'code': '123456',
        'name': 'Song 2',
        'updatedAt': '2026-01-08T10:00:00Z',
        'resources': [
          {
            'id': '2',
            'name': 'Resource 2',
            'type': 'image',
            'imageUrls': ['https://example.com/image2.jpg'],
          },
        ],
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
