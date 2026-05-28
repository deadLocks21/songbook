import 'package:songbook/core/application/dtos/remote_song.dto.dart';
import 'package:songbook/core/domain/model/remote_song.dart';
import 'package:songbook/core/domain/services/remote_song.repository.dart';

/// Implémentation du RemoteSongRepository en mémoire.
class InMemoryRemoteSongRepository implements RemoteSongRepository {
  InMemoryRemoteSongRepository();

  @override
  Future<List<RemoteSong>> fetchSongs(
    String baseUrl, {
    List<String> recueils = const [],
  }) async {
    const jsonList = [
      {
        'id': '7cba49da-a9d1-4b7f-8e46-bf4ea27570cc',
        'code': 'JEM799',
        'name': 'Nous annonçons le Roi',
        'updatedAt': '2026-01-08T10:00:00Z',
        'resources': [
          {
            'id': '33fe9c36-2124-48c3-b6b4-43796e885f0d',
            'name': 'Partition',
            'type': 'image',
            'imageUrls': [
              'https://timothe.hofmann.fr/Partitions/JEM/jem799/0001.jpg',
              'https://timothe.hofmann.fr/Partitions/JEM/jem799/0002.jpg',
            ],
          },
        ],
      },
      {
        'id': '1eef82e2-4ead-4c2b-90c9-adf3af3fe09b',
        'code': 'JEM876',
        'name': 'Mon rédempteur vit',
        'updatedAt': '2026-01-08T10:00:00Z',
        'resources': [
          {
            'id': '58ed430f-4ca9-4fec-9bee-addf92ff2c9e',
            'name': 'Partition',
            'type': 'image',
            'imageUrls': [
              'https://timothe.hofmann.fr/Partitions/JEM/jem876/0001.jpg',
              'https://timothe.hofmann.fr/Partitions/JEM/jem876/0002.jpg',
            ],
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
