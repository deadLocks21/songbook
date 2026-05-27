import 'package:songbook/core/domain/model/uuid_value.dart';

/// Interface pour mettre en cache les ressources distantes à la demande.
///
/// Le cache n'a pas de durée de péremption : une ressource déjà téléchargée
/// n'est jamais re-téléchargée. Il n'existe pas de moyen de forcer le
/// re-téléchargement (hors vidage complet du cache).
abstract interface class ResourceCacheRepository {
  /// Retourne le chemin local de la ressource pointée par [url].
  ///
  /// Si la ressource est déjà présente en cache, son chemin est retourné sans
  /// téléchargement. Sinon, elle est téléchargée, mise en cache, puis son
  /// chemin local est retourné.
  ///
  /// [songId] sert à organiser les fichiers par chant dans le cache.
  Future<String> getCachedResource(String url, UuidValue songId);

  /// Retourne le chemin du dossier racine du cache des ressources.
  String getCacheDirectory();
}
