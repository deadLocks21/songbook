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

    final documentsDirectory = await getApplicationSupportDirectory();
    final path = p.join(documentsDirectory.path, 'songbook.db');

    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
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

    // Créer les tables des listes de chants
    await _createSongListTables(db);
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await _createSongListTables(db);
    }
    if (oldVersion < 3) {
      // Transposition enregistree par chant et par liste (nullable : pas de
      // backfill, les lignes existantes restent a NULL).
      await db.execute(
        'ALTER TABLE song_list_entries ADD COLUMN savedSemitones INTEGER',
      );
    }
    if (oldVersion < 4) {
      // Passage des listes en ressource serveur synchronisee.
      //
      // `dirty` vaut 1 par defaut : les listes deja presentes sur l'appareil
      // n'ont jamais ete poussees, elles partiront donc au premier push. Avec
      // `serverVersion` a NULL, ce push sera une creation.
      await db.execute('ALTER TABLE song_lists ADD COLUMN title TEXT');
      await db.execute('ALTER TABLE song_lists ADD COLUMN serverVersion INTEGER');
      await db.execute(
        'ALTER TABLE song_lists ADD COLUMN dirty INTEGER NOT NULL DEFAULT 1',
      );
      await db.execute(
        'ALTER TABLE song_lists ADD COLUMN pendingDeletion INTEGER NOT NULL DEFAULT 0',
      );
    }
  }

  /// Crée les tables des listes de chants au schéma courant.
  ///
  /// Exposé pour que les tests montent une base en mémoire avec exactement le
  /// même schéma que l'application, plutôt qu'une copie du DDL qui pourrait en
  /// diverger sans que rien ne le signale.
  static Future<void> createSongListTables(Database db) =>
      _createSongListTables(db);

  static Future<void> _createSongListTables(Database db) async {
    await db.execute('''
      CREATE TABLE song_lists (
        id TEXT PRIMARY KEY,
        scheduledAt TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        title TEXT,
        serverVersion INTEGER,
        dirty INTEGER NOT NULL DEFAULT 1,
        pendingDeletion INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE song_list_entries (
        id TEXT PRIMARY KEY,
        songListId TEXT NOT NULL,
        songId TEXT NOT NULL,
        position INTEGER NOT NULL,
        savedSemitones INTEGER,
        FOREIGN KEY (songListId) REFERENCES song_lists (id) ON DELETE CASCADE,
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
    await db.delete('song_list_entries');
    await db.delete('song_lists');
    await db.delete('resources');
    await db.delete('songs');

    // Réinitialiser les auto-increments si nécessaire
    await db.execute('VACUUM');
  }

  /// Supprime complètement le fichier de base de données
  static Future<void> deleteDatabaseFile() async {
    final documentsDirectory = await getApplicationSupportDirectory();
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
