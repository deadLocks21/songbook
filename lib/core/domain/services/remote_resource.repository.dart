import 'package:songbook/core/domain/model/uuid_value.dart';

/// Interface pour télécharger et gérer les ressources distantes.
abstract interface class RemoteResourceRepository {
  /// Télécharge une ressource depuis une URL et la sauvegarde localement.
  /// Retourne le chemin local du fichier sauvegardé.
  ///
  /// [url] est l'URL complète de la ressource à télécharger.
  /// [songId] est l'identifiant du song associé (pour organiser les fichiers).
  /// [filename] est le nom du fichier à créer localement.
  Future<String> downloadResource(
    String url,
    UuidValue songId,
    String filename,
  );

  /// Supprime toutes les ressources locales associées à un song.
  ///
  /// [songId] est l'identifiant du song dont on supprime les ressources.
  Future<void> deleteResourcesForSong(UuidValue songId);

  /// Retourne le chemin du dossier racine contenant les ressources.
  String getResourcesDirectory();
}
