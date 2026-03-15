import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:songbook/core/domain/services/settings.repository.dart';

/// Cas d'usage pour définir le répertoire de synchronisation.
///
/// Copie les fichiers de l'ancien emplacement vers le nouveau,
/// puis met à jour le paramètre.
class SetSyncDirectoryUseCase {
  final SettingsRepository _settingsRepository;

  SetSyncDirectoryUseCase(this._settingsRepository);

  /// Exécute le changement de répertoire de synchronisation.
  ///
  /// [newPath] : le nouveau chemin, ou null pour revenir à l'emplacement par défaut.
  /// [onProgress] : callback optionnel (0.0 à 1.0) pour suivre la progression de la copie.
  Future<void> execute(String? newPath, {void Function(double)? onProgress}) async {
    final oldPath = await _resolveCurrentPath();
    final targetPath = newPath ?? await _defaultResourcesPath();

    // Si le chemin n'a pas changé, ne rien faire
    if (oldPath == targetPath) {
      await _settingsRepository.setSyncDirectory(newPath);
      return;
    }

    // Copier les fichiers de l'ancien vers le nouveau répertoire
    final oldDir = Directory(oldPath);
    if (await oldDir.exists()) {
      final targetDir = Directory(targetPath);
      await targetDir.create(recursive: true);

      final files = await _listFilesRecursively(oldDir);
      for (var i = 0; i < files.length; i++) {
        final file = files[i];
        final relativePath = file.path.substring(oldDir.path.length);
        final newFile = File('$targetPath$relativePath');
        await newFile.parent.create(recursive: true);
        await file.copy(newFile.path);

        onProgress?.call((i + 1) / files.length);
      }

      // Supprimer l'ancien répertoire après copie réussie
      await oldDir.delete(recursive: true);
    }

    // Sauvegarder le nouveau chemin
    await _settingsRepository.setSyncDirectory(newPath);
  }

  /// Résout le chemin actuel des ressources (personnalisé ou par défaut)
  Future<String> _resolveCurrentPath() async {
    final customPath = await _settingsRepository.getSyncDirectory();
    if (customPath != null) return customPath;
    return await _defaultResourcesPath();
  }

  /// Retourne le chemin par défaut des ressources
  Future<String> _defaultResourcesPath() async {
    final appDir = await getApplicationSupportDirectory();
    return '${appDir.path}/resources';
  }

  /// Liste récursivement tous les fichiers d'un répertoire
  Future<List<File>> _listFilesRecursively(Directory dir) async {
    final files = <File>[];
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        files.add(entity);
      }
    }
    return files;
  }
}
