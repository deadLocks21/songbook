import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/core/application/usecases/cache_recueil_partitions.usecase.dart';
import 'package:songbook/core/domain/model/remote_song.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/resource_cache.repository.dart';

/// Cache espion : mémorise les URLs demandées au lieu de télécharger.
class _SpyResourceCacheRepository implements ResourceCacheRepository {
  final List<({String url, UuidValue songId})> requested = [];

  @override
  Future<String> getCachedResource(String url, UuidValue songId) async {
    requested.add((url: url, songId: songId));
    return '/cache/$url';
  }

  @override
  Future<bool> isResourceCached(String url, UuidValue songId) async => false;

  @override
  String getCacheDirectory() => '/cache';
}

void main() {
  late _SpyResourceCacheRepository cache;
  late CacheRecueilPartitionsUseCase useCase;

  final id1 = UuidValue.parse('00000000-0000-4000-a000-000000000001');
  final id2 = UuidValue.parse('00000000-0000-4000-a000-000000000002');
  final id3 = UuidValue.parse('00000000-0000-4000-a000-000000000003');
  final resId = UuidValue.parse('00000000-0000-4000-b000-000000000001');

  RemoteSong songIn(UuidValue id, List<String> recueils, List<String> urls) {
    return RemoteSong(
      id: id,
      code: 'C-${id.value.substring(0, 4)}',
      name: 'Song',
      updatedAt: DateTime(2024, 1, 1),
      recueils: recueils,
      resources: [
        RemoteImageResource(id: resId, name: 'Partition', imageUrls: urls),
      ],
    );
  }

  setUp(() {
    cache = _SpyResourceCacheRepository();
    useCase = CacheRecueilPartitionsUseCase(cache);
  });

  group('CacheRecueilPartitionsUseCase', () {
    test('met en cache uniquement les chants des recueils sélectionnés',
        () async {
      final songs = [
        songIn(id1, ['REC-001'], ['a.jpg', 'b.jpg']),
        songIn(id2, ['REC-002'], ['c.jpg']),
        songIn(id3, ['REC-001', 'REC-003'], ['d.jpg']),
      ];

      await useCase.execute(songs, {'REC-001'});

      final urls = cache.requested.map((r) => r.url).toList();
      expect(urls, containsAll(['a.jpg', 'b.jpg', 'd.jpg']));
      expect(urls, isNot(contains('c.jpg')));
    });

    test('ne télécharge rien si aucun recueil sélectionné', () async {
      final songs = [
        songIn(id1, ['REC-001'], ['a.jpg']),
      ];

      await useCase.execute(songs, <String>{});

      expect(cache.requested, isEmpty);
    });

    test('rapporte la progression jusqu\'au total', () async {
      final songs = [
        songIn(id1, ['REC-001'], ['a.jpg', 'b.jpg']),
      ];

      final progress = <({int done, int total})>[];
      await useCase.execute(
        songs,
        {'REC-001'},
        onProgress: (done, total) => progress.add((done: done, total: total)),
      );

      expect(progress.first, (done: 0, total: 2));
      expect(progress.last, (done: 2, total: 2));
    });
  });
}
