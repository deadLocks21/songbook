import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/remote_resource.repository.dart';

/// Implémentation en mémoire du RemoteResourceRepository.
/// Utilisé pour le web et les tests.
/// Au lieu de télécharger les fichiers, retourne directement l'URL comme chemin.
class InMemoryRemoteResourceRepository implements RemoteResourceRepository {
  @override
  Future<String> downloadResource(
    String url,
    UuidValue songId,
    String filename,
  ) async {
    // Sur le web, on retourne directement l'URL au lieu de télécharger
    return url;
  }

  @override
  Future<void> deleteResourcesForSong(UuidValue songId) async {
    // Rien à supprimer en mémoire
  }

  @override
  String getResourcesDirectory() => '';
}
