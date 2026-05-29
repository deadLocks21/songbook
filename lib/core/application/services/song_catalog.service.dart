import 'dart:io';

import 'package:songbook/core/application/dtos/song.dto.dart';
import 'package:songbook/core/domain/services/resource_cache.repository.dart';
import 'package:songbook/core/domain/services/song.repository.dart';

class SongCatalogService {
  final SongRepository _songRepository;
  final ResourceCacheRepository _resourceCacheRepository;

  const SongCatalogService(this._songRepository, this._resourceCacheRepository);

  Future<List<SongDto>> getAllSongs() async {
    final songs = List.of(await _songRepository.getAllSongs());
    songs.sort((a, b) => a.code.compareTo(b.code));
    return songs.map(SongDto.fromDomain).toList();
  }

  Future<void> clearDatabase() async {
    // Le cache disque n'existe qu'avec une implémentation sur fichiers. En mode
    // démo/en mémoire, `getCacheDirectory()` renvoie une chaîne vide : il n'y a
    // rien à supprimer (et surtout pas `Directory('')`, le répertoire courant).
    final cachePath = _resourceCacheRepository.getCacheDirectory();
    if (cachePath.isNotEmpty) {
      final cacheDir = Directory(cachePath);
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    }
    await _songRepository.deleteAllSongs();
  }
}
