import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/application/usecases/compute_sync_diff.usecase.dart';
import 'package:songbook/core/application/usecases/execute_sync.usecase.dart';
import 'package:songbook/core/domain/exceptions/password_required.exception.dart';
import 'package:songbook/core/domain/services/remote_resource.repository.dart';
import 'package:songbook/core/domain/services/remote_song.repository.dart';
import 'package:songbook/infrastructure/resource/dio.remote_resource.repository.dart';
import 'package:songbook/infrastructure/song/dio.remote_song.repository.dart';
import 'package:songbook/infrastructure/song/providers/song.repository_provider.dart';
import 'package:songbook/infrastructure/settings/providers/settings.repository_provider.dart';

part 'sync.providers.g.dart';

/// Intercepteur Dio pour gérer l'authentification par mot de passe
class _AuthInterceptor extends Interceptor {
  final Ref _ref;

  _AuthInterceptor(this._ref);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Récupérer le mot de passe stocké et l'ajouter au header X-Password
    final settingsRepository = _ref.read(settingsRepositoryProvider);
    final password = await settingsRepository.getPassword();

    if (password != null) {
      options.headers['X-Password'] = password;
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Intercepter les erreurs 401 et 403 pour demander un mot de passe
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      // Créer une nouvelle exception avec PasswordRequiredException comme cause
      final passwordException = DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: PasswordRequiredException(),
      );
      handler.reject(passwordException);
      return;
    }

    handler.next(err);
  }
}

/// Intercepteur Dio pour ajouter la version de l'application dans les headers
class _VersionInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Récupérer les informations de l'application
    final packageInfo = await PackageInfo.fromPlatform();

    // Ajouter la version complète (version + buildNumber) au header X-App-Version
    final appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    options.headers['X-App-Version'] = appVersion;

    handler.next(options);
  }
}

/// Provider pour l'instance Dio utilisée pour les requêtes HTTP.
@riverpod
Dio dio(Ref ref) {
  final dio = Dio();

  // Ajouter l'intercepteur d'authentification
  dio.interceptors.add(_AuthInterceptor(ref));

  // Ajouter l'intercepteur de version
  dio.interceptors.add(_VersionInterceptor());

  return dio;
}

/// Provider pour le repository des songs distants.
@riverpod
RemoteSongRepository remoteSongRepository(Ref ref) {
  // return InMemoryRemoteSongRepository();
  final dio = ref.watch(dioProvider);
  return DioRemoteSongRepository(dio);
}

/// Provider pour le repository des ressources distantes.
/// Retourne un Future car nécessite le chemin du répertoire de l'application.
@riverpod
Future<RemoteResourceRepository> remoteResourceRepository(Ref ref) async {
  final dio = ref.watch(dioProvider);
  final appDir = await getApplicationSupportDirectory();
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
