import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/core/application/usecases/set_sync_directory.usecase.dart';
import 'package:songbook/infrastructure/settings/in_memory.settings_repository.dart';

void main() {
  late Directory tmpDefaultDir;
  late InMemorySettingsRepository settingsRepository;

  setUp(() {
    tmpDefaultDir = Directory.systemTemp.createTempSync(
      'songbook_test_sync_default_',
    );
    settingsRepository = InMemorySettingsRepository();
  });

  tearDown(() {
    if (tmpDefaultDir.existsSync()) {
      tmpDefaultDir.deleteSync(recursive: true);
    }
  });

  SetSyncDirectoryUseCase createUseCase() {
    return SetSyncDirectoryUseCase(
      settingsRepository,
      defaultPathResolver: () async => tmpDefaultDir.path,
    );
  }

  /// Crée des fichiers de test dans un répertoire donné.
  Future<void> createTestFiles(String dirPath) async {
    final dir = Directory(dirPath);
    await dir.create(recursive: true);
    await File('$dirPath/song1/image.jpg').create(recursive: true);
    await File('$dirPath/song1/image.jpg').writeAsString('image data');
    await File('$dirPath/song2/doc.pdf').create(recursive: true);
    await File('$dirPath/song2/doc.pdf').writeAsString('pdf data');
  }

  group('SetSyncDirectoryUseCase', () {
    test('copies files from default to new directory', () async {
      await createTestFiles(tmpDefaultDir.path);

      final newDir = Directory.systemTemp.createTempSync(
        'songbook_test_sync_new_',
      );
      addTearDown(() {
        if (newDir.existsSync()) newDir.deleteSync(recursive: true);
      });

      final useCase = createUseCase();
      await useCase.execute(newDir.path);

      // Fichiers dans le nouveau répertoire
      expect(File('${newDir.path}/song1/image.jpg').existsSync(), isTrue);
      expect(
        File('${newDir.path}/song1/image.jpg').readAsStringSync(),
        'image data',
      );
      expect(File('${newDir.path}/song2/doc.pdf').existsSync(), isTrue);
      expect(
        File('${newDir.path}/song2/doc.pdf').readAsStringSync(),
        'pdf data',
      );

      // Ancien répertoire supprimé
      expect(tmpDefaultDir.existsSync(), isFalse);

      // Settings mis à jour
      expect(await settingsRepository.getSyncDirectory(), newDir.path);
    });

    test('does nothing when paths are identical', () async {
      await createTestFiles(tmpDefaultDir.path);

      // Configurer le custom dir au même chemin que le default
      await settingsRepository.setSyncDirectory(tmpDefaultDir.path);

      final useCase = createUseCase();
      await useCase.execute(tmpDefaultDir.path);

      // Fichiers toujours en place
      expect(
        File('${tmpDefaultDir.path}/song1/image.jpg').existsSync(),
        isTrue,
      );

      // Settings sauvegardé
      expect(
        await settingsRepository.getSyncDirectory(),
        tmpDefaultDir.path,
      );
    });

    test('migrates from custom back to default', () async {
      final customDir = Directory.systemTemp.createTempSync(
        'songbook_test_sync_custom_',
      );
      addTearDown(() {
        if (customDir.existsSync()) customDir.deleteSync(recursive: true);
      });

      await createTestFiles(customDir.path);
      await settingsRepository.setSyncDirectory(customDir.path);

      final useCase = createUseCase();
      // null → retour au default
      await useCase.execute(null);

      // Fichiers dans le répertoire par défaut
      expect(
        File('${tmpDefaultDir.path}/song1/image.jpg').existsSync(),
        isTrue,
      );
      expect(
        File('${tmpDefaultDir.path}/song2/doc.pdf').existsSync(),
        isTrue,
      );

      // Custom supprimé
      expect(customDir.existsSync(), isFalse);

      // Settings remis à null (default)
      expect(await settingsRepository.getSyncDirectory(), isNull);
    });

    test('reports progress correctly', () async {
      await createTestFiles(tmpDefaultDir.path);

      final newDir = Directory.systemTemp.createTempSync(
        'songbook_test_sync_progress_',
      );
      addTearDown(() {
        if (newDir.existsSync()) newDir.deleteSync(recursive: true);
      });

      final progressValues = <double>[];
      final useCase = createUseCase();
      await useCase.execute(
        newDir.path,
        onProgress: (value) => progressValues.add(value),
      );

      expect(progressValues, isNotEmpty);
      // Chaque valeur est croissante
      for (var i = 1; i < progressValues.length; i++) {
        expect(progressValues[i], greaterThan(progressValues[i - 1]));
      }
      // La dernière valeur est 1.0
      expect(progressValues.last, 1.0);
    });

    test('handles empty source directory', () async {
      // Créer le répertoire default vide
      await tmpDefaultDir.create(recursive: true);

      final newDir = Directory.systemTemp.createTempSync(
        'songbook_test_sync_empty_',
      );
      addTearDown(() {
        if (newDir.existsSync()) newDir.deleteSync(recursive: true);
      });

      final useCase = createUseCase();
      // Ne doit pas crasher
      await useCase.execute(newDir.path);

      expect(await settingsRepository.getSyncDirectory(), newDir.path);
    });

    test('creates target directory if it does not exist', () async {
      await createTestFiles(tmpDefaultDir.path);

      final newPath =
          '${Directory.systemTemp.path}/songbook_test_sync_create_${DateTime.now().millisecondsSinceEpoch}';
      addTearDown(() {
        final dir = Directory(newPath);
        if (dir.existsSync()) dir.deleteSync(recursive: true);
      });

      expect(Directory(newPath).existsSync(), isFalse);

      final useCase = createUseCase();
      await useCase.execute(newPath);

      expect(Directory(newPath).existsSync(), isTrue);
      expect(File('$newPath/song1/image.jpg').existsSync(), isTrue);
    });
  });
}
