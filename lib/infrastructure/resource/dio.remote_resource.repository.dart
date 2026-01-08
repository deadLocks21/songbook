import 'dart:io';

import 'package:dio/dio.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/remote_resource.repository.dart';

/// Implémentation du RemoteResourceRepository utilisant Dio pour télécharger les fichiers.
class DioRemoteResourceRepository implements RemoteResourceRepository {
  final Dio _dio;
  final String _baseDirectory;

  DioRemoteResourceRepository(this._dio, this._baseDirectory);

  @override
  Future<String> downloadResource(
    String url,
    UuidValue songId,
    String filename,
  ) async {
    final songDir = '$_baseDirectory/${songId.value}';
    await Directory(songDir).create(recursive: true);

    final filePath = '$songDir/$filename';
    await _dio.download(url, filePath);

    return filePath;
  }

  @override
  Future<void> deleteResourcesForSong(UuidValue songId) async {
    final songDir = Directory('$_baseDirectory/${songId.value}');
    if (await songDir.exists()) {
      await songDir.delete(recursive: true);
    }
  }

  @override
  String getResourcesDirectory() => _baseDirectory;
}
