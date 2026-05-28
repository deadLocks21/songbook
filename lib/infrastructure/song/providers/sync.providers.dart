import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/application/services/sync.service.dart';
import 'package:songbook/core/domain/services/auth_token_store.dart';
import 'package:songbook/core/domain/services/remote_song.repository.dart';
import 'package:songbook/core/domain/services/resource_cache.repository.dart';
import 'package:songbook/infrastructure/auth/providers/auth_token_store.provider.dart';
import 'package:songbook/infrastructure/resource/dio.resource_cache.repository.dart';
import 'package:songbook/infrastructure/resource/in_memory.resource_cache.repository.dart';
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

  _AuthInterceptor(this._tokenStore);

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
  dio.interceptors.add(_AuthInterceptor(ref.watch(authTokenStoreProvider)));

  return dio;
}

/// Provider pour le repository des songs distants.
/// Utilise InMemoryRemoteSongRepository sur le web (CORS empêche les appels Dio directs).
@riverpod
RemoteSongRepository remoteSongRepository(Ref ref) {
  if (kIsWeb) {
    return InMemoryRemoteSongRepository();
  }
  final dio = ref.watch(dioProvider);
  return DioRemoteSongRepository(dio);
}

/// Provider pour le cache des ressources (images/PDF).
/// Utilise InMemoryResourceCacheRepository sur le web.
/// Retourne un Future car nécessite le chemin du répertoire de l'application (hors web).
@riverpod
Future<ResourceCacheRepository> resourceCacheRepository(Ref ref) async {
  if (kIsWeb) {
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
