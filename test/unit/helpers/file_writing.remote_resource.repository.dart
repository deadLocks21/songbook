import 'dart:io';

import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/remote_resource.repository.dart';

/// Implémentation de test qui écrit de vrais fichiers sur disque.
/// Simule le comportement de DioRemoteResourceRepository sans HTTP.
class FileWritingRemoteResourceRepository implements RemoteResourceRepository {
  final String _baseDirectory;

  FileWritingRemoteResourceRepository(this._baseDirectory);

  @override
  Future<String> downloadResource(
    String url,
    UuidValue songId,
    String filename,
  ) async {
    final songDir = Directory('$_baseDirectory/${songId.value}');
    await songDir.create(recursive: true);
    final filePath = '${songDir.path}/$filename';
    await File(filePath).writeAsString('fake content from $url');
    return filePath;
  }

  @override
  Future<void> deleteResourcesForSong(UuidValue songId) async {
    final dir = Directory('$_baseDirectory/${songId.value}');
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  @override
  String getResourcesDirectory() => _baseDirectory;
}
