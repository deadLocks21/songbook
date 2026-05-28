import 'dart:io';

import 'package:dio/dio.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/resource_cache.repository.dart';

/// Implémentation du [ResourceCacheRepository] basée sur Dio.
///
/// Les fichiers sont stockés dans `<baseDirectory>/<songId>/<filename>`, le
/// nom de fichier étant dérivé de l'URL. Avant tout téléchargement, on vérifie
/// la présence du fichier en cache.
class DioResourceCacheRepository implements ResourceCacheRepository {
  final Dio _dio;
  final String _baseDirectory;

  DioResourceCacheRepository(this._dio, this._baseDirectory);

  @override
  Future<String> getCachedResource(String url, UuidValue songId) async {
    final songDir = '$_baseDirectory/${songId.value}';
    final filename = _extractFilename(url);
    final filePath = '$songDir/$filename';

    // Cache hit : le fichier existe déjà localement, on évite le téléchargement.
    if (await File(filePath).exists()) {
      return filePath;
    }

    await Directory(songDir).create(recursive: true);
    await _dio.download(url, filePath);

    return filePath;
  }

  @override
  Future<bool> isResourceCached(String url, UuidValue songId) async {
    final filePath = '$_baseDirectory/${songId.value}/${_extractFilename(url)}';
    return File(filePath).exists();
  }

  @override
  String getCacheDirectory() => _baseDirectory;

  /// Dérive un nom de fichier déterministe depuis une URL.
  ///
  /// Le dernier segment du chemin est utilisé s'il ressemble à un fichier
  /// (présence d'une extension). À défaut, on retombe sur un nom dérivé du
  /// hash de l'URL pour rester stable d'un appel à l'autre.
  String _extractFilename(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        final lastSegment = pathSegments.last;
        if (lastSegment.isNotEmpty && lastSegment.contains('.')) {
          return lastSegment;
        }
      }
    } catch (_) {
      // Parsing impossible : on retombe sur le nom par défaut ci-dessous.
    }
    return 'resource_${url.hashCode}';
  }
}
