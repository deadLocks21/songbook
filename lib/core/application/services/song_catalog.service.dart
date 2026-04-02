import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:songbook/core/application/dtos/song.dto.dart';
import 'package:songbook/core/domain/services/remote_resource.repository.dart';
import 'package:songbook/core/domain/services/song.repository.dart';

class SongCatalogService {
  final SongRepository _songRepository;
  final RemoteResourceRepository _resourceRepository;

  const SongCatalogService(this._songRepository, this._resourceRepository);

  Future<List<SongDto>> getAllSongs() async {
    final songs = List.of(await _songRepository.getAllSongs());
    songs.sort((a, b) => a.code.compareTo(b.code));
    return songs.map(SongDto.fromDomain).toList();
  }

  Future<void> clearDatabase() async {
    if (!kIsWeb) {
      final resourcesDir =
          Directory(_resourceRepository.getResourcesDirectory());
      if (await resourcesDir.exists()) {
        await resourcesDir.delete(recursive: true);
      }
    }
    await _songRepository.deleteAllSongs();
  }
}
