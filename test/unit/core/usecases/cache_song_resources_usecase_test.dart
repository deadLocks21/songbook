import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/core/application/dtos/resource.dto.dart';
import 'package:songbook/core/application/dtos/song.dto.dart';
import 'package:songbook/core/application/services/logger_application.service.dart';
import 'package:songbook/core/application/usecases/cache_song_resources.usecase.dart';
import 'package:songbook/core/domain/model/log_level.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/logger.service.dart';
import 'package:songbook/core/domain/services/resource_cache.repository.dart';

/// Cache factice qui enregistre les URLs demandées et peut simuler des échecs.
class _RecordingCache implements ResourceCacheRepository {
  final List<String> requested = [];
  final Set<String> failUrls;

  _RecordingCache({this.failUrls = const {}});

  @override
  Future<String> getCachedResource(String url, UuidValue songId) async {
    requested.add(url);
    if (failUrls.contains(url)) throw Exception('boom');
    return url;
  }

  @override
  Future<bool> isResourceCached(String url, UuidValue songId) async => false;

  @override
  String getCacheDirectory() => '/tmp';
}

class _NoopLogger implements LoggerService {
  @override
  Future<void> log(
    LogLevel level,
    String message, {
    Map<String, Object?> attributes = const {},
    Object? error,
    StackTrace? stack,
  }) async {}

  @override
  Future<void> flush() async {}
}

void main() {
  final logger = LoggerApplicationService(_NoopLogger());
  const songId = '00000000-0000-4000-a000-000000000001';
  const resId = '00000000-0000-4000-b000-00000000000';

  SongDto songWith(List<ResourceDto> resources) => SongDto(
    id: songId,
    code: 'C001',
    name: 'Test',
    updatedAt: DateTime(2025),
    resources: resources,
  );

  test('met en cache toutes les URLs (images, chordpro, pdf)', () async {
    final cache = _RecordingCache();
    final song = songWith(const [
      ImageResourceDto(id: '${resId}1', name: 'img', imageUrls: ['a', 'b']),
      ChordProResourceDto(id: '${resId}2', name: 'cho', chordProUrl: 'c'),
      PdfResourceDto(id: '${resId}3', name: 'pdf', pdfUrl: 'd'),
    ]);

    await CacheSongResourcesUseCase(cache, logger).execute(song);

    expect(cache.requested, ['a', 'b', 'c', 'd']);
  });

  test('best-effort : un échec n\'interrompt pas le reste', () async {
    final cache = _RecordingCache(failUrls: {'a'});
    final song = songWith(const [
      ImageResourceDto(id: '${resId}1', name: 'img', imageUrls: ['a', 'b']),
    ]);

    await CacheSongResourcesUseCase(cache, logger).execute(song);

    // 'a' tenté (échec) puis 'b' tout de même tenté.
    expect(cache.requested, ['a', 'b']);
  });
}
