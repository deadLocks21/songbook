import 'dart:io';

import 'package:songbook/core/domain/services/song.repository.dart';
import 'package:songbook/core/domain/services/remote_resource.repository.dart';

/// Use case pour vider complètement la base de données
class ClearDatabaseUseCase {
  final SongRepository _songRepository;
  final RemoteResourceRepository _resourceRepository;

  const ClearDatabaseUseCase(this._songRepository, this._resourceRepository);

  /// Vide complètement la base de données et supprime tous les fichiers de ressources
  Future<void> execute() async {
    // D'abord supprimer tous les fichiers physiques
    await _deleteAllResourceFiles();

    // Puis supprimer les données de la base
    await _songRepository.deleteAllSongs();
  }

  /// Supprime tous les fichiers de ressources physiques
  Future<void> _deleteAllResourceFiles() async {
    final resourcesDir = Directory(_resourceRepository.getResourcesDirectory());
    if (await resourcesDir.exists()) {
      await resourcesDir.delete(recursive: true);
    }
  }
}
