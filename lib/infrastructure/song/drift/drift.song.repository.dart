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

    // Récupérer tous les chants
    final songRows = await db.query('songs');

    final songs = <domain_song.Song>[];

    for (final songRow in songRows) {
      // Récupérer les ressources pour ce chant
      final resourceRows = await db.query(
        'resources',
        where: 'songId = ?',
        whereArgs: [songRow['id']],
      );

      final resources = resourceRows.map(_resourceRowToDomain).toList();

      songs.add(
        domain_song.Song(
          id: UuidValue.parse(songRow['id'] as String),
          code: songRow['code'] as String,
          name: songRow['name'] as String,
          updatedAt: DateTime.parse(songRow['updatedAt'] as String),
          resources: resources,
        ),
      );
    }

    return songs;
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

    // La suppression en cascade supprimera automatiquement les ressources
    await db.delete('songs', where: 'id = ?', whereArgs: [id.value]);
  }

  @override
  Future<void> deleteAllSongs() async {
    final db = await _database;

    // Supprimer tous les chants (les ressources seront supprimées en cascade)
    await db.delete('songs');
  }

  /// Convertit une ligne de ressource en objet Resource du domaine
  Resource _resourceRowToDomain(Map<String, dynamic> row) {
    final jsonData = jsonDecode(row['data'] as String) as Map<String, dynamic>;

    switch (row['type']) {
      case 'image':
        final imagePaths = (jsonData['imagePaths'] as List<dynamic>)
            .map((path) => path as String)
            .toList();
        return ImageResource(
          id: UuidValue.parse(row['id'] as String),
          name: row['name'] as String,
          imagePaths: imagePaths,
        );

      case 'pdf':
        return PdfResource(
          id: UuidValue.parse(row['id'] as String),
          name: row['name'] as String,
          pdfPath: jsonData['pdfPath'] as String,
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
    };
  }

  /// Convertit une ressource en JSON
  String _resourceToJson(Resource resource) {
    final jsonData = switch (resource) {
      ImageResource() => {'imagePaths': resource.imagePaths},
      PdfResource() => {'pdfPath': resource.pdfPath},
    };
    return jsonEncode(jsonData);
  }
}
