import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Classe utilitaire pour gérer la base de données SQLite
class AppDatabase {
  static Database? _database;
  static bool _isInitialized = false;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    // Initialiser sqflite pour les plateformes non-mobile
    if (!_isInitialized) {
      // Vérifier si on est sur une plateforme desktop
      // Sur mobile (iOS/Android), sqflite est déjà initialisé
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        // Pour les plateformes desktop
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      _isInitialized = true;
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = p.join(documentsDirectory.path, 'songbook.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Créer la table des chants
    await db.execute('''
      CREATE TABLE songs (
        id TEXT PRIMARY KEY,
        code TEXT NOT NULL,
        name TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Créer la table des ressources
    await db.execute('''
      CREATE TABLE resources (
        id TEXT PRIMARY KEY,
        songId TEXT NOT NULL,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        data TEXT NOT NULL,
        FOREIGN KEY (songId) REFERENCES songs (id) ON DELETE CASCADE
      )
    ''');
  }

  /// Ferme la base de données
  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Vide complètement la base de données
  static Future<void> clearDatabase() async {
    final db = await database;

    // Supprimer toutes les tables
    await db.delete('resources');
    await db.delete('songs');

    // Réinitialiser les auto-increments si nécessaire
    await db.execute('VACUUM');
  }

  /// Supprime complètement le fichier de base de données
  static Future<void> deleteDatabaseFile() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = p.join(documentsDirectory.path, 'songbook.db');

    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }

    // Fermer la connexion actuelle
    await close();

    // Réinitialiser l'état pour forcer une recréation
    _database = null;
    _isInitialized = false;
  }
}
