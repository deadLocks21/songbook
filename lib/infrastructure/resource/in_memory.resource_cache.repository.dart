import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/resource_cache.repository.dart';

/// Implémentation en mémoire du [ResourceCacheRepository].
///
/// Utilisée sur le web (pas de système de fichiers) et dans les tests : aucune
/// mise en cache disque, l'URL est retournée telle quelle et chargée
/// directement via le réseau.
class InMemoryResourceCacheRepository implements ResourceCacheRepository {
  @override
  Future<String> getCachedResource(String url, UuidValue songId) async => url;

  @override
  Future<bool> isResourceCached(String url, UuidValue songId) async => false;

  @override
  String getCacheDirectory() => '';
}
