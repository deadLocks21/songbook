import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/infrastructure/resource/dio.resource_cache.repository.dart';

import '../../helpers/fake_dio.dart';

/// FakeDio qui compte les téléchargements pour vérifier le comportement de
/// cache (pas de re-téléchargement si le fichier existe déjà).
class _CountingFakeDio extends FakeDio {
  int downloadCount = 0;

  @override
  Future<Response> download(
    String urlPath,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    FileAccessMode fileAccessMode = FileAccessMode.write,
    String lengthHeader = Headers.contentLengthHeader,
    Object? data,
    Options? options,
  }) {
    downloadCount++;
    return super.download(urlPath, savePath);
  }
}

void main() {
  late Directory tmpDir;
  late DioResourceCacheRepository repository;
  late _CountingFakeDio fakeDio;

  final songId = UuidValue.parse('00000000-0000-4000-a000-000000000001');

  setUp(() {
    tmpDir = Directory.systemTemp.createTempSync('songbook_test_cache_repo_');
    fakeDio = _CountingFakeDio();
    repository = DioResourceCacheRepository(fakeDio, tmpDir.path);
  });

  tearDown(() {
    if (tmpDir.existsSync()) {
      tmpDir.deleteSync(recursive: true);
    }
  });

  group('DioResourceCacheRepository', () {
    test('downloads and caches the resource on a cache miss', () async {
      final path = await repository.getCachedResource(
        'https://example.com/image.jpg',
        songId,
      );

      expect(path, '${tmpDir.path}/${songId.value}/image.jpg');
      expect(File(path).existsSync(), isTrue);
      expect(fakeDio.downloadCount, 1);
    });

    test('returns the cached path without re-downloading on a cache hit', () async {
      const url = 'https://example.com/image.jpg';

      final first = await repository.getCachedResource(url, songId);
      final second = await repository.getCachedResource(url, songId);

      expect(second, first);
      // Un seul téléchargement malgré deux appels : le cache est réutilisé.
      expect(fakeDio.downloadCount, 1);
    });

    test('stores resources of different songs in separate directories', () async {
      final songId2 = UuidValue.parse('00000000-0000-4000-a000-000000000002');

      await repository.getCachedResource('https://example.com/a.jpg', songId);
      await repository.getCachedResource('https://example.com/b.jpg', songId2);

      expect(
        File('${tmpDir.path}/${songId.value}/a.jpg').existsSync(),
        isTrue,
      );
      expect(
        File('${tmpDir.path}/${songId2.value}/b.jpg').existsSync(),
        isTrue,
      );
    });

    test('getCacheDirectory returns the base directory', () {
      expect(repository.getCacheDirectory(), tmpDir.path);
    });
  });
}
