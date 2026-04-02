import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/infrastructure/resource/dio.remote_resource.repository.dart';

import '../../helpers/fake_dio.dart';

void main() {
  late Directory tmpDir;
  late DioRemoteResourceRepository repository;
  late FakeDio fakeDio;

  setUp(() {
    tmpDir = Directory.systemTemp.createTempSync('songbook_test_dio_repo_');
    fakeDio = FakeDio();
    repository = DioRemoteResourceRepository(fakeDio, tmpDir.path);
  });

  tearDown(() {
    if (tmpDir.existsSync()) {
      tmpDir.deleteSync(recursive: true);
    }
  });

  group('DioRemoteResourceRepository', () {
    test('downloadResource creates directory and file', () async {
      final songId = UuidValue.parse('00000000-0000-4000-a000-000000000001');
      final path = await repository.downloadResource(
        'https://example.com/image.jpg',
        songId,
        'image.jpg',
      );

      expect(path, '${tmpDir.path}/${songId.value}/image.jpg');
      expect(File(path).existsSync(), isTrue);
      expect(
        File(path).readAsStringSync(),
        'fake content from https://example.com/image.jpg',
      );
    });

    test('downloadResource for multiple songs creates separate dirs', () async {
      final songId1 = UuidValue.parse('00000000-0000-4000-a000-000000000001');
      final songId2 = UuidValue.parse('00000000-0000-4000-a000-000000000002');

      await repository.downloadResource(
        'https://example.com/a.jpg',
        songId1,
        'a.jpg',
      );
      await repository.downloadResource(
        'https://example.com/b.jpg',
        songId2,
        'b.jpg',
      );

      expect(
        Directory('${tmpDir.path}/${songId1.value}').existsSync(),
        isTrue,
      );
      expect(
        Directory('${tmpDir.path}/${songId2.value}').existsSync(),
        isTrue,
      );
      expect(
        File('${tmpDir.path}/${songId1.value}/a.jpg').existsSync(),
        isTrue,
      );
      expect(
        File('${tmpDir.path}/${songId2.value}/b.jpg').existsSync(),
        isTrue,
      );
    });

    test('deleteResourcesForSong removes the song directory', () async {
      final songId = UuidValue.parse('00000000-0000-4000-a000-000000000001');

      await repository.downloadResource(
        'https://example.com/image.jpg',
        songId,
        'image.jpg',
      );
      expect(
        Directory('${tmpDir.path}/${songId.value}').existsSync(),
        isTrue,
      );

      await repository.deleteResourcesForSong(songId);

      expect(
        Directory('${tmpDir.path}/${songId.value}').existsSync(),
        isFalse,
      );
    });

    test('getResourcesDirectory returns base directory', () {
      expect(repository.getResourcesDirectory(), tmpDir.path);
    });
  });
}
