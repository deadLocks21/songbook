# Plan: Implémentation Sync Source avec Base de Données Locale

## Objectif
Créer deux use cases pour synchroniser les songs depuis une source distante (URL) vers la base de données locale :
1. **ComputeSyncDiffUseCase** : Calcule les différences entre les données distantes et locales
2. **ExecuteSyncUseCase** : Exécute les actions de synchronisation (ajout, mise à jour, suppression)

## Architecture Respectée
- **Domain** : Modèles et interfaces pures (pas de Riverpod, pas de HTTP)
- **Application** : Use cases, DTOs, orchestration
- **Infrastructure** : Implémentations concrètes, providers Riverpod

---

## Étape 1 : Modifier le modèle Song (Domain)

### Fichier : `lib/core/domain/model/song.dart`
Ajouter le champ `updatedAt` au modèle Song :
```dart
class Song {
  final UuidValue id;
  final String code;
  final String name;
  final List<Resource> resources;
  final DateTime updatedAt;  // NOUVEAU
  // ...
}
```

---

## Étape 2 : Créer le modèle RemoteSong (Domain)

### Fichier : `lib/core/domain/model/remote_song.dart`
Modèle distinct pour représenter un song distant (ne réutilise PAS Song) :
```dart
/// Représente un song tel que reçu du serveur distant.
/// Distinct de Song car contient des URLs au lieu de chemins locaux.
class RemoteSong {
  final UuidValue id;
  final String code;
  final String name;
  final DateTime updatedAt;
  final List<RemoteResource> resources;
}

/// Ressource distante avec URLs
sealed class RemoteResource {
  UuidValue get id;
  String get name;
}

class RemoteImageResource extends RemoteResource {
  @override
  final UuidValue id;
  @override
  final String name;
  final List<String> imageUrls;  // URLs des images
}

class RemotePdfResource extends RemoteResource {
  @override
  final UuidValue id;
  @override
  final String name;
  final String pdfUrl;  // URL du PDF
}
```

---

## Étape 3 : Créer le modèle SyncDiff (Domain)

### Fichier : `lib/core/domain/model/sync_diff.dart`
Modèle représentant les différences calculées :
```dart
class SyncDiff {
  final List<SongToAdd> toAdd;        // Songs à ajouter (nouveaux)
  final List<SongToUpdate> toUpdate;  // Songs à mettre à jour (updated_at plus récent)
  final List<SongToDelete> toDelete;  // Songs à supprimer (disparus du serveur)
}

class SongToAdd {
  final RemoteSong remoteSong;
}

class SongToUpdate {
  final Song localSong;
  final RemoteSong remoteSong;
}

class SongToDelete {
  final Song localSong;
}
```

---

## Étape 4 : Modifier et créer les interfaces Repository (Domain)

### Fichier : `lib/core/domain/services/song.repository.dart` (MODIFIER)
Étendre l'interface existante avec les opérations d'écriture :
```dart
abstract interface class SongRepository {
  // Lecture (existant)
  Future<List<Song>> getAllSongs();

  // Écriture (nouveau)
  Future<void> addSong(Song song);
  Future<void> updateSong(Song song);  // UPDATE au lieu de delete+add
  Future<void> deleteSong(UuidValue id);
  Future<void> deleteAllSongs();
}
```

### Fichier : `lib/core/domain/services/remote_song.repository.dart` (CRÉER)
Interface pour récupérer les songs distants :
```dart
abstract interface class RemoteSongRepository {
  Future<List<RemoteSong>> fetchSongs(String baseUrl);
}
```

### Fichier : `lib/core/domain/services/remote_resource.repository.dart` (CRÉER)
Interface pour télécharger et gérer les ressources distantes :
```dart
abstract interface class RemoteResourceRepository {
  /// Télécharge une ressource depuis une URL et la sauvegarde localement
  /// Retourne le chemin local du fichier
  Future<String> downloadResource(String url, UuidValue songId, String filename);

  /// Supprime toutes les ressources locales d'un song
  Future<void> deleteResourcesForSong(UuidValue songId);

  /// Retourne le chemin du dossier de ressources
  String getResourcesDirectory();
}
```

---

## Étape 5 : Créer les DTOs (Application)

### Fichier : `lib/core/application/dtos/sync_diff.dto.dart`
DTOs pour exposer les résultats de sync à l'UI :
```dart
enum SyncActionType { add, update, delete }

class SyncDiffDto {
  final int toAddCount;
  final int toUpdateCount;
  final int toDeleteCount;
  final List<SongSyncActionDto> actions;
}

class SongSyncActionDto {
  final String songId;
  final String songName;
  final SyncActionType type;
}
```

### Fichier : `lib/core/application/dtos/remote_song.dto.dart`
DTO pour parser le JSON de l'API :
```dart
class RemoteSongDto {
  final String id;
  final String code;
  final String name;
  final DateTime updatedAt;
  final List<RemoteResourceDto> resources;

  factory RemoteSongDto.fromJson(Map<String, dynamic> json);
  RemoteSong toDomain();  // Convertit vers le domain RemoteSong
}

sealed class RemoteResourceDto {
  factory RemoteResourceDto.fromJson(Map<String, dynamic> json);
  RemoteResource toDomain();
}

class RemoteImageResourceDto extends RemoteResourceDto {
  final String id;
  final String name;
  final List<String> imageUrls;
}

class RemotePdfResourceDto extends RemoteResourceDto {
  final String id;
  final String name;
  final String pdfUrl;
}
```

---

## Étape 6 : Créer les Use Cases (Application)

### Fichier : `lib/core/application/usecases/compute_sync_diff.usecase.dart`
```dart
class ComputeSyncDiffUseCase {
  final SongRepository localRepository;
  final RemoteSongRepository remoteRepository;

  Future<SyncDiff> execute(String baseUrl) async {
    final localSongs = await localRepository.getAllSongs();
    final remoteSongs = await remoteRepository.fetchSongs(baseUrl);

    final localById = {for (final s in localSongs) s.id: s};
    final remoteById = {for (final s in remoteSongs) s.id: s};

    final toAdd = <SongToAdd>[];
    final toUpdate = <SongToUpdate>[];
    final toDelete = <SongToDelete>[];

    // Songs à ajouter ou mettre à jour
    for (final remote in remoteSongs) {
      final local = localById[remote.id];
      if (local == null) {
        toAdd.add(SongToAdd(remoteSong: remote));
      } else if (remote.updatedAt.isAfter(local.updatedAt)) {
        toUpdate.add(SongToUpdate(localSong: local, remoteSong: remote));
      }
    }

    // Songs à supprimer (présents localement mais pas sur le serveur)
    for (final local in localSongs) {
      if (!remoteById.containsKey(local.id)) {
        toDelete.add(SongToDelete(localSong: local));
      }
    }

    return SyncDiff(toAdd: toAdd, toUpdate: toUpdate, toDelete: toDelete);
  }
}
```

### Fichier : `lib/core/application/usecases/execute_sync.usecase.dart`
```dart
class ExecuteSyncUseCase {
  final SongRepository songRepository;
  final RemoteResourceRepository resourceRepository;

  Future<void> execute(SyncDiff diff) async {
    // 1. Supprimer les songs disparus
    for (final toDelete in diff.toDelete) {
      await resourceRepository.deleteResourcesForSong(toDelete.localSong.id);
      await songRepository.deleteSong(toDelete.localSong.id);
    }

    // 2. Mettre à jour les songs modifiés (supprimer ressources + télécharger + UPDATE)
    for (final toUpdate in diff.toUpdate) {
      await resourceRepository.deleteResourcesForSong(toUpdate.localSong.id);
      final localResources = await _downloadResources(toUpdate.remoteSong);
      final updatedSong = _createSongFromRemote(toUpdate.remoteSong, localResources);
      await songRepository.updateSong(updatedSong);  // UPDATE, pas delete+add
    }

    // 3. Ajouter les nouveaux songs
    for (final toAdd in diff.toAdd) {
      final localResources = await _downloadResources(toAdd.remoteSong);
      final newSong = _createSongFromRemote(toAdd.remoteSong, localResources);
      await songRepository.addSong(newSong);
    }
  }

  Future<List<Resource>> _downloadResources(RemoteSong remoteSong) async {
    // Télécharge chaque ressource et retourne les Resource avec chemins locaux
  }

  Song _createSongFromRemote(RemoteSong remote, List<Resource> localResources) {
    return Song(
      id: remote.id,
      code: remote.code,
      name: remote.name,
      updatedAt: remote.updatedAt,
      resources: localResources,
    );
  }
}
```

---

## Étape 7 : Implémenter les Repositories (Infrastructure)

### Fichier : `lib/infrastructure/song/dio.remote_song.repository.dart` (CRÉER)
```dart
class DioRemoteSongRepository implements RemoteSongRepository {
  final Dio dio;

  @override
  Future<List<RemoteSong>> fetchSongs(String baseUrl) async {
    final response = await dio.get(baseUrl);
    final List<dynamic> jsonList = response.data;
    return jsonList
        .map((json) => RemoteSongDto.fromJson(json).toDomain())
        .toList();
  }
}
```

### Fichier : `lib/infrastructure/song/drift/drift.song.repository.dart` (MODIFIER)
```dart
class DriftSongRepository implements SongRepository {
  final AppDatabase db;

  @override
  Future<List<Song>> getAllSongs() async { /* implémenter */ }

  @override
  Future<void> addSong(Song song) async { /* implémenter */ }

  @override
  Future<void> updateSong(Song song) async { /* UPDATE en base */ }

  @override
  Future<void> deleteSong(UuidValue id) async { /* implémenter */ }

  @override
  Future<void> deleteAllSongs() async { /* implémenter */ }
}
```

### Fichier : `lib/infrastructure/song/in_memory.song.repository.dart` (MODIFIER)
```dart
class InMemorySongRepository implements SongRepository {
  @override
  Future<void> addSong(Song song) async { _songs.add(song); }

  @override
  Future<void> updateSong(Song song) async {
    final index = _songs.indexWhere((s) => s.id == song.id);
    if (index != -1) _songs[index] = song;
  }

  @override
  Future<void> deleteSong(UuidValue id) async {
    _songs.removeWhere((s) => s.id == id);
  }

  @override
  Future<void> deleteAllSongs() async { _songs.clear(); }
}
```

### Fichier : `lib/infrastructure/resource/dio.remote_resource.repository.dart` (CRÉER)
```dart
class DioRemoteResourceRepository implements RemoteResourceRepository {
  final Dio dio;
  final String baseDirectory;

  @override
  Future<String> downloadResource(String url, UuidValue songId, String filename) async {
    final songDir = '$baseDirectory/${songId.value}';
    await Directory(songDir).create(recursive: true);
    final filePath = '$songDir/$filename';
    await dio.download(url, filePath);
    return filePath;
  }

  @override
  Future<void> deleteResourcesForSong(UuidValue songId) async {
    final songDir = Directory('$baseDirectory/${songId.value}');
    if (await songDir.exists()) {
      await songDir.delete(recursive: true);
    }
  }

  @override
  String getResourcesDirectory() => baseDirectory;
}
```

---

## Étape 8 : Créer les Providers (Infrastructure)

### Fichier : `lib/infrastructure/song/providers/sync.providers.dart`
```dart
@riverpod
Dio dio(Ref ref) => Dio();

@riverpod
RemoteSongRepository remoteSongRepository(Ref ref) {
  return DioRemoteSongRepository(ref.watch(dioProvider));
}

@riverpod
Future<RemoteResourceRepository> remoteResourceRepository(Ref ref) async {
  final appDir = await getApplicationDocumentsDirectory();
  return DioRemoteResourceRepository(
    ref.watch(dioProvider),
    '${appDir.path}/resources',
  );
}

@riverpod
ComputeSyncDiffUseCase computeSyncDiffUseCase(Ref ref) {
  return ComputeSyncDiffUseCase(
    ref.watch(songRepositoryProvider),
    ref.watch(remoteSongRepositoryProvider),
  );
}

@riverpod
Future<ExecuteSyncUseCase> executeSyncUseCase(Ref ref) async {
  return ExecuteSyncUseCase(
    ref.watch(songRepositoryProvider),
    await ref.watch(remoteResourceRepositoryProvider.future),
  );
}
```

---

## Étape 9 : Mettre à jour les DTOs existants

### Fichier : `lib/core/application/dtos/song.dto.dart`
Ajouter le champ `updatedAt` :
```dart
class SongDto {
  final String id;
  final String code;
  final String name;
  final DateTime updatedAt;  // NOUVEAU
  final List<ResourceDto> resources;
  // Mettre à jour fromDomain, toDomain, toJson, fromJson
}
```

---

## Fichiers à créer/modifier

### Nouveaux fichiers (11)
| # | Fichier | Description |
|---|---------|-------------|
| 1 | `lib/core/domain/model/remote_song.dart` | Modèle RemoteSong distinct |
| 2 | `lib/core/domain/model/sync_diff.dart` | Modèle SyncDiff |
| 3 | `lib/core/domain/services/remote_song.repository.dart` | Interface fetch distant |
| 4 | `lib/core/domain/services/remote_resource.repository.dart` | Interface téléchargement ressources |
| 5 | `lib/core/application/dtos/sync_diff.dto.dart` | DTOs sync pour UI |
| 6 | `lib/core/application/dtos/remote_song.dto.dart` | DTOs parsing JSON API |
| 7 | `lib/core/application/usecases/compute_sync_diff.usecase.dart` | Use case calcul différences |
| 8 | `lib/core/application/usecases/execute_sync.usecase.dart` | Use case exécution sync |
| 9 | `lib/infrastructure/song/dio.remote_song.repository.dart` | Implémentation Dio fetch |
| 10 | `lib/infrastructure/resource/dio.remote_resource.repository.dart` | Implémentation Dio download |
| 11 | `lib/infrastructure/song/providers/sync.providers.dart` | Providers Riverpod |

### Fichiers à modifier (5)
| # | Fichier | Modification |
|---|---------|--------------|
| 1 | `lib/core/domain/model/song.dart` | Ajouter `updatedAt` |
| 2 | `lib/core/domain/services/song.repository.dart` | Ajouter `addSong`, `updateSong`, `deleteSong`, `deleteAllSongs` |
| 3 | `lib/core/application/dtos/song.dto.dart` | Ajouter `updatedAt` |
| 4 | `lib/infrastructure/song/in_memory.song.repository.dart` | Ajouter `updatedAt` + méthodes d'écriture |
| 5 | `lib/infrastructure/song/drift/drift.song.repository.dart` | Implémenter complètement |

---

## Dépendances à ajouter

```yaml
# pubspec.yaml
dependencies:
  dio: ^5.4.0  # Pour les requêtes HTTP et téléchargement
  # path_provider: déjà présent (^2.1.5)
```

---

## Notes d'implémentation

1. **Pas de Riverpod dans Domain/Application** : Les use cases reçoivent leurs dépendances par constructeur
2. **Imports absolus** : Tous les imports en `package:songbook/...`
3. **L'UI n'appelle jamais directement les repositories** : Elle passe par les use cases
4. **Les use cases ne sont pas utilisés pour le moment** : Juste créés et disponibles
5. **SongRepository unifié** : Une seule interface pour lecture ET écriture
6. **RemoteSong distinct de Song** : Modèle séparé pour les données distantes (URLs vs chemins locaux)
7. **UPDATE au lieu de DELETE+ADD** : Pour les mises à jour, on utilise `updateSong()` après suppression des ressources
