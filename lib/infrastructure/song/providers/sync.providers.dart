import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/application/services/sync.service.dart';
import 'package:songbook/core/domain/services/auth_token_store.dart';
import 'package:songbook/core/domain/services/remote_song.repository.dart';
import 'package:songbook/core/domain/services/resource_cache.repository.dart';
import 'package:songbook/infrastructure/auth/providers/auth_token_store.provider.dart';
import 'package:songbook/infrastructure/auth/providers/session_revocation.provider.dart';
import 'package:songbook/infrastructure/resource/dio.resource_cache.repository.dart';
import 'package:songbook/infrastructure/resource/in_memory.resource_cache.repository.dart';
import 'package:songbook/infrastructure/settings/providers/in_memory_mode.provider.dart';
import 'package:songbook/infrastructure/song/dio.remote_song.repository.dart';
import 'package:songbook/infrastructure/song/in_memory.remote_song.repository.dart';
import 'package:songbook/infrastructure/song/providers/song.repository_provider.dart';

part 'sync.providers.g.dart';

/// Intercepteur Dio pour ajouter la version de l'application dans les headers.
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

/// Ajoute l'en-tête `Authorization: Bearer <jwt>` aux routes protégées et
/// purge la session locale quand l'API répond `401 invalid_token` (token
/// absent/expiré/invalide) — cf. API.md.
class _AuthInterceptor extends Interceptor {
  final AuthTokenStore _tokenStore;
  final void Function() _onUnauthorized;

  _AuthInterceptor(this._tokenStore, this._onUnauthorized);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Les endpoints d'authentification sont publics : pas de Bearer.
    if (!options.uri.path.contains('/api/auth/')) {
      final session = await _tokenStore.read();
      if (session != null) {
        options.headers['Authorization'] = 'Bearer ${session.token}';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final data = err.response?.data;
    final code = data is Map<String, dynamic> ? data['code'] : null;
    if (err.response?.statusCode == 401 && code == 'invalid_token') {
      // Token absent/expiré/invalide : on purge la session locale et on
      // signale l'UI pour relancer le flux OTP (cf. API.md).
      await _tokenStore.clear();
      _onUnauthorized();
    }
    handler.next(err);
  }
}

/// Provider pour l'instance Dio utilisée pour les requêtes HTTP.
@riverpod
Dio dio(Ref ref) {
  // Des timeouts explicites sont indispensables : sans eux, un backend
  // injoignable (connexion TCP qui pend sans réponse, ex. port filtré par un
  // pare-feu) bloquerait la synchronisation indéfiniment. Avec timeout, l'échec
  // remonte sous forme de DioException et l'app peut prévenir puis continuer.
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  dio.interceptors.add(_VersionInterceptor());
  dio.interceptors.add(
    _AuthInterceptor(
      ref.watch(authTokenStoreProvider),
      () => ref.read(sessionRevocationProvider.notifier).signal(),
    ),
  );

  return dio;
}

/// Provider pour le repository des songs distants.
/// En mémoire en mode démo (web, aucune URL, ou URL « memory »),
/// appels Dio sinon — cf. [inMemoryModeProvider].
@riverpod
RemoteSongRepository remoteSongRepository(Ref ref) {
  if (ref.watch(inMemoryModeProvider)) {
    return InMemoryRemoteSongRepository();
  }
  final dio = ref.watch(dioProvider);
  return DioRemoteSongRepository(dio);
}

/// Provider pour le cache des ressources (images/PDF).
/// En mémoire en mode démo (web, aucune URL, ou URL « memory ») : aucune
/// écriture disque — cf. [inMemoryModeProvider]. Retourne un Future car la
/// version sur fichiers nécessite le chemin du répertoire de l'application.
@riverpod
Future<ResourceCacheRepository> resourceCacheRepository(Ref ref) async {
  if (ref.watch(inMemoryModeProvider)) {
    return InMemoryResourceCacheRepository();
  }
  final dio = ref.watch(dioProvider);
  final appDir = await getApplicationSupportDirectory();
  final resourcesPath = '${appDir.path}/resources';
  return DioResourceCacheRepository(dio, resourcesPath);
}

/// Provider pour le service de synchronisation.
@riverpod
SyncService syncService(Ref ref) {
  final songRepository = ref.watch(songRepositoryProvider);
  final remoteSongRepository = ref.watch(remoteSongRepositoryProvider);
  return SyncService(songRepository, remoteSongRepository);
}
