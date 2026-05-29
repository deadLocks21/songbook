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
  /// [onProgress] est appelé avec le nombre de **chants** déjà traités et le
  /// total de chants, pour alimenter une barre de progression cohérente avec le
  /// reste de l'UI (qui raisonne en chants). Une partition qui échoue est
  /// ignorée (best effort) : on ne fait pas échouer tout le téléchargement pour
  /// une image manquante.
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

    final total = targets.length;
    var done = 0;
    onProgress?.call(done, total);

    for (final song in targets) {
      for (final resource in song.resources) {
        final urls = switch (resource) {
          RemoteImageResource(:final imageUrls) => imageUrls,
          RemotePdfResource(:final pdfUrl) => [pdfUrl],
          RemoteChordProResource(:final chordProUrl) => [chordProUrl],
        };
        for (final url in urls) {
          try {
            await _cache.getCachedResource(url, song.id);
          } catch (_) {
            // Best effort : on poursuit malgré l'échec d'une partition.
          }
        }
      }
      done++;
      onProgress?.call(done, total);
    }
  }
}
