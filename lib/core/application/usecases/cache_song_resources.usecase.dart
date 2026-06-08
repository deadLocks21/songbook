import 'package:songbook/core/application/dtos/resource.dto.dart';
import 'package:songbook/core/application/dtos/song.dto.dart';
import 'package:songbook/core/application/services/logger_application.service.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/resource_cache.repository.dart';

/// Pré-télécharge et met en cache toutes les ressources (images, PDF, ChordPro)
/// d'un chant, en best-effort.
///
/// Utilisé à l'ajout d'un chant dans une liste afin de le rendre consultable
/// hors-ligne sans attendre son premier affichage. Une ressource qui échoue est
/// journalisée puis ignorée : on ne fait pas échouer toute la mise en cache pour
/// un fichier manquant. On opère sur le [SongDto] (et non l'entité domaine) pour
/// éviter toute conversion susceptible d'échouer et d'annuler silencieusement la
/// mise en cache.
class CacheSongResourcesUseCase {
  final ResourceCacheRepository _cache;
  final LoggerApplicationService _logger;

  CacheSongResourcesUseCase(this._cache, this._logger);

  Future<void> execute(SongDto song) async {
    final songId = UuidValue.parse(song.id);
    var cached = 0;
    var failed = 0;

    for (final resource in song.resources) {
      final urls = switch (resource) {
        ImageResourceDto(:final imageUrls) => imageUrls,
        PdfResourceDto(:final pdfUrl) => [pdfUrl],
        ChordProResourceDto(:final chordProUrl) => [chordProUrl],
      };
      for (final url in urls) {
        try {
          await _cache.getCachedResource(url, songId);
          cached++;
        } catch (e, stack) {
          failed++;
          _logger.error(
            'setlist.cache_resource.failed',
            attrs: {'songId': song.id, 'url': url},
            error: e,
            stack: stack,
          );
        }
      }
    }

    _logger.info(
      'setlist.cache_song.done',
      attrs: {'songId': song.id, 'cached': cached, 'failed': failed},
    );
  }
}
