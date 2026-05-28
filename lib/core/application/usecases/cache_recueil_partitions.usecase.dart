import 'package:songbook/core/domain/model/remote_song.dart';
import 'package:songbook/core/domain/services/resource_cache.repository.dart';

/// Télécharge et met en cache localement toutes les partitions (images / PDF)
/// des chants appartenant aux recueils sélectionnés.
///
/// La synchronisation de la **liste** des chants reste exhaustive ; ce use case
/// ne fait que pré-télécharger les ressources des recueils cochés afin qu'ils
/// soient consultables hors-ligne.
class CacheRecueilPartitionsUseCase {
  final ResourceCacheRepository _cache;

  CacheRecueilPartitionsUseCase(this._cache);

  /// Met en cache les partitions des [songs] dont au moins un recueil figure
  /// dans [selectedRecueils].
  ///
  /// [onProgress] est appelé après chaque ressource traitée avec le nombre de
  /// ressources déjà traitées et le total, pour alimenter une barre de
  /// progression. Une ressource qui échoue est ignorée (best effort) : on ne
  /// fait pas échouer toute la synchronisation pour une partition manquante.
  Future<void> execute(
    List<RemoteSong> songs,
    Set<String> selectedRecueils, {
    void Function(int done, int total)? onProgress,
  }) async {
    if (selectedRecueils.isEmpty) {
      return;
    }

    final targets = songs
        .where((s) => s.recueils.any(selectedRecueils.contains))
        .toList();

    // Aplatit (songId, url) pour toutes les ressources image/PDF à télécharger.
    final downloads = <({String url, RemoteSong song})>[];
    for (final song in targets) {
      for (final resource in song.resources) {
        switch (resource) {
          case RemoteImageResource(:final imageUrls):
            for (final url in imageUrls) {
              downloads.add((url: url, song: song));
            }
          case RemotePdfResource(:final pdfUrl):
            downloads.add((url: pdfUrl, song: song));
        }
      }
    }

    final total = downloads.length;
    var done = 0;
    onProgress?.call(done, total);

    for (final d in downloads) {
      try {
        await _cache.getCachedResource(d.url, d.song.id);
      } catch (_) {
        // Best effort : on poursuit malgré l'échec d'une partition.
      }
      done++;
      onProgress?.call(done, total);
    }
  }
}
