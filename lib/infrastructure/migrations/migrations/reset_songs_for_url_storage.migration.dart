import 'package:songbook/infrastructure/migrations/migration.dart';

/// Réinitialise les chants stockés avec l'ancien format (chemins de fichiers
/// locaux) pour qu'ils soient re-synchronisés au format URL.
///
/// Avant cette feature, les ressources étaient téléchargées lors de la sync et
/// la base stockait des **chemins locaux** (`imagePaths`/`pdfPath`). Désormais
/// la base stocke des **URLs** (`imageUrls`/`pdfUrl`), les fichiers étant mis
/// en cache à la demande. Les anciennes lignes `resources` sont donc illisibles
/// par le nouveau code.
///
/// Plutôt que de vider la table `songs` (ce qui détruirait les playlists via
/// le `ON DELETE CASCADE` de `song_list_entries`), on supprime uniquement les
/// `resources` et on remet `songs.updatedAt` à l'epoch : la prochaine
/// synchronisation considère alors chaque chant comme « à mettre à jour » et
/// repeuple les ressources au format URL, en conservant les IDs (donc les
/// playlists).
///
/// Les fichiers déjà présents dans le dossier `resources/` restent valides : le
/// cache à la demande les réutilise (mêmes noms de fichiers dérivés des URLs).
class ResetSongsForUrlStorageMigration extends Migration {
  static const _epoch = '1970-01-01T00:00:00.000Z';

  @override
  String get id => '2026_05_27_reset_songs_for_url_storage';

  @override
  Future<bool> shouldRun(MigrationContext ctx) async {
    // Présence d'au moins une ressource à l'ancien format (clés de chemins).
    final rows = await ctx.db.rawQuery(
      "SELECT 1 FROM resources "
      "WHERE data LIKE '%\"imagePaths\"%' OR data LIKE '%\"pdfPath\"%' "
      "LIMIT 1",
    );
    return rows.isNotEmpty;
  }

  @override
  Future<void> execute(MigrationContext ctx) async {
    final deleted = await ctx.db.delete('resources');
    final reset = await ctx.db.update('songs', {'updatedAt': _epoch});
    ctx.logger.info(
      'migration.songs.reset_for_url_storage',
      attrs: {'resources.deleted': deleted, 'songs.reset': reset},
    );
  }
}
