import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:songbook/core/domain/model/resource.dart';
import 'package:songbook/core/domain/model/song.dart' as domain_song;
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/song.repository.dart';
import 'package:songbook/infrastructure/song/drift/drift_database.dart';

/// Implémentation du SongRepository utilisant SQLite.
/// Récupère et gère les chants depuis la base de données SQLite.
class DriftSongRepository implements SongRepository {
  const DriftSongRepository();
  Future<Database> get _database => AppDatabase.database;

  @override
  Future<List<domain_song.Song>> getAllSongs() async {
    final db = await _database;

    // Deux requêtes seulement : tous les chants, puis toutes les ressources en
    // une fois, regroupées par chant en mémoire. Évite le N+1 (une requête de
    // ressources par chant) qui dominait le temps de synchronisation.
    final songRows = await db.query('songs');
    final resourceRows = await db.query('resources');

    final resourcesBySongId = _groupResourcesBySongId(resourceRows);

    return [
      for (final songRow in songRows)
        _songRowToDomain(
          songRow,
          resourcesBySongId[songRow['id'] as String] ?? const [],
        ),
    ];
  }

  @override
  Future<List<domain_song.Song>> getSongsByIds(List<UuidValue> ids) async {
    if (ids.isEmpty) return [];
    final db = await _database;

    final placeholders = List.filled(ids.length, '?').join(', ');
    final idValues = ids.map((id) => id.value).toList();

    // Deux requêtes seulement (cf. getAllSongs) : les chants demandés puis
    // leurs ressources, regroupées en mémoire — au lieu d'un N+1.
    final songRows = await db.query(
      'songs',
      where: 'id IN ($placeholders)',
      whereArgs: idValues,
    );
    final resourceRows = await db.query(
      'resources',
      where: 'songId IN ($placeholders)',
      whereArgs: idValues,
    );

    final resourcesBySongId = _groupResourcesBySongId(resourceRows);

    return [
      for (final songRow in songRows)
        _songRowToDomain(
          songRow,
          resourcesBySongId[songRow['id'] as String] ?? const [],
        ),
    ];
  }

  @override
  Future<void> addSong(domain_song.Song song) async {
    final db = await _database;

    // Insérer le chant
    await db.insert('songs', {
      'id': song.id.value,
      'code': song.code,
      'name': song.name,
      'updatedAt': song.updatedAt.toIso8601String(),
    });

    // Insérer les ressources
    for (final resource in song.resources) {
      await db.insert('resources', {
        'id': resource.id.value,
        'songId': song.id.value,
        'name': resource.name,
        'type': _getResourceType(resource),
        'data': _resourceToJson(resource),
      });
    }
  }

  @override
  Future<void> updateSong(domain_song.Song song) async {
    final db = await _database;

    // Supprimer les anciennes ressources
    await db.delete(
      'resources',
      where: 'songId = ?',
      whereArgs: [song.id.value],
    );

    // Mettre à jour le chant
    await db.update(
      'songs',
      {
        'code': song.code,
        'name': song.name,
        'updatedAt': song.updatedAt.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [song.id.value],
    );

    // Insérer les nouvelles ressources
    for (final resource in song.resources) {
      await db.insert('resources', {
        'id': resource.id.value,
        'songId': song.id.value,
        'name': resource.name,
        'type': _getResourceType(resource),
        'data': _resourceToJson(resource),
      });
    }
  }

  @override
  Future<void> deleteSong(UuidValue id) async {
    final db = await _database;

    // La suppression en cascade supprimera automatiquement les ressources (si foreign keys activées)
    await db.delete('songs', where: 'id = ?', whereArgs: [id.value]);

    // Au cas où les foreign keys ne sont pas activées, supprimer aussi manuellement les ressources
    await db.delete('resources', where: 'songId = ?', whereArgs: [id.value]);
  }

  @override
  Future<void> deleteAllSongs() async {
    final db = await _database;

    // Supprimer tous les chants (les ressources seront supprimées en cascade si foreign keys activées)
    await db.delete('songs');

    // Au cas où les foreign keys ne sont pas activées, supprimer aussi manuellement les ressources
    await db.delete('resources');
  }

  /// Regroupe des lignes de la table `resources` par `songId`, en préservant
  /// l'ordre d'apparition des ressources pour un même chant.
  Map<String, List<Resource>> _groupResourcesBySongId(
    List<Map<String, Object?>> rows,
  ) {
    final bySongId = <String, List<Resource>>{};
    for (final row in rows) {
      final songId = row['songId'] as String;
      (bySongId[songId] ??= <Resource>[]).add(_resourceRowToDomain(row));
    }
    return bySongId;
  }

  /// Construit un [domain_song.Song] depuis une ligne `songs` et ses ressources.
  domain_song.Song _songRowToDomain(
    Map<String, Object?> songRow,
    List<Resource> resources,
  ) {
    return domain_song.Song(
      id: UuidValue.parse(songRow['id'] as String),
      code: songRow['code'] as String,
      name: songRow['name'] as String,
      updatedAt: DateTime.parse(songRow['updatedAt'] as String),
      resources: resources,
    );
  }

  /// Convertit une ligne de ressource en objet Resource du domaine
  Resource _resourceRowToDomain(Map<String, dynamic> row) {
    final jsonData = jsonDecode(row['data'] as String) as Map<String, dynamic>;

    switch (row['type']) {
      case 'image':
        final imageUrls = (jsonData['imageUrls'] as List<dynamic>)
            .map((url) => url as String)
            .toList();
        return ImageResource(
          id: UuidValue.parse(row['id'] as String),
          name: row['name'] as String,
          imageUrls: imageUrls,
        );

      case 'pdf':
        return PdfResource(
          id: UuidValue.parse(row['id'] as String),
          name: row['name'] as String,
          pdfUrl: jsonData['pdfUrl'] as String,
        );

      case 'chordpro':
        return ChordProResource(
          id: UuidValue.parse(row['id'] as String),
          name: row['name'] as String,
          chordProUrl: jsonData['chordProUrl'] as String,
        );

      default:
        throw UnsupportedError('Unknown resource type: ${row['type']}');
    }
  }

  /// Détermine le type de ressource
  String _getResourceType(Resource resource) {
    return switch (resource) {
      ImageResource() => 'image',
      PdfResource() => 'pdf',
      ChordProResource() => 'chordpro',
    };
  }

  /// Convertit une ressource en JSON
  String _resourceToJson(Resource resource) {
    final jsonData = switch (resource) {
      ImageResource() => {'imageUrls': resource.imageUrls},
      PdfResource() => {'pdfUrl': resource.pdfUrl},
      ChordProResource() => {'chordProUrl': resource.chordProUrl},
    };
    return jsonEncode(jsonData);
  }
}
