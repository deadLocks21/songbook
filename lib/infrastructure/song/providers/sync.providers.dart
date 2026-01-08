import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/application/usecases/compute_sync_diff.usecase.dart';
import 'package:songbook/core/application/usecases/execute_sync.usecase.dart';
import 'package:songbook/core/domain/services/remote_resource.repository.dart';
import 'package:songbook/core/domain/services/remote_song.repository.dart';
import 'package:songbook/infrastructure/resource/dio.remote_resource.repository.dart';
import 'package:songbook/infrastructure/song/dio.remote_song.repository.dart';
import 'package:songbook/infrastructure/song/in_memory.remote_song.repository.dart';
import 'package:songbook/infrastructure/song/providers/song.repository_provider.dart';

part 'sync.providers.g.dart';

/// Provider pour l'instance Dio utilisée pour les requêtes HTTP.
@riverpod
Dio dio(Ref ref) {
  return Dio();
}

/// Provider pour le repository des songs distants.
@riverpod
RemoteSongRepository remoteSongRepository(Ref ref) {
  return InMemoryRemoteSongRepository();
  // final dio = ref.watch(dioProvider);
  // return DioRemoteSongRepository(dio);
}

/// Provider pour le repository des ressources distantes.
/// Retourne un Future car nécessite le chemin du répertoire de l'application.
@riverpod
Future<RemoteResourceRepository> remoteResourceRepository(Ref ref) async {
  final dio = ref.watch(dioProvider);
  final appDir = await getApplicationDocumentsDirectory();
  final resourcesPath = '${appDir.path}/resources';
  return DioRemoteResourceRepository(dio, resourcesPath);
}

/// Provider pour le use case de calcul des différences de synchronisation.
@riverpod
ComputeSyncDiffUseCase computeSyncDiffUseCase(Ref ref) {
  final localRepository = ref.watch(songRepositoryProvider);
  final remoteRepository = ref.watch(remoteSongRepositoryProvider);
  return ComputeSyncDiffUseCase(localRepository, remoteRepository);
}

/// Provider pour le use case d'exécution de la synchronisation.
/// Retourne un Future car dépend du RemoteResourceRepository async.
@riverpod
Future<ExecuteSyncUseCase> executeSyncUseCase(Ref ref) async {
  final songRepository = ref.watch(songRepositoryProvider);
  final resourceRepository = await ref.watch(
    remoteResourceRepositoryProvider.future,
  );
  return ExecuteSyncUseCase(songRepository, resourceRepository);
}
