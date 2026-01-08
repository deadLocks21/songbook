import 'package:songbook/core/domain/model/resource.dart';
import 'package:songbook/core/domain/model/song.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/song.repository.dart';

/// Implémentation en mémoire du SongRepository.
/// Utilisé pour le développement et les tests.
/// Contient des données d'exemple statiques.
class InMemorySongRepository implements SongRepository {
  final List<Song> _songs;

  InMemorySongRepository() : _songs = _createSampleData();

  @override
  Future<List<Song>> getAllSongs() async {
    // Retourne une copie non modifiable
    return List.unmodifiable(_songs);
  }

  @override
  Future<void> addSong(Song song) async {
    _songs.add(song);
  }

  @override
  Future<void> updateSong(Song song) async {
    final index = _songs.indexWhere((s) => s.id == song.id);
    if (index != -1) {
      _songs[index] = song;
    }
  }

  @override
  Future<void> deleteSong(UuidValue id) async {
    _songs.removeWhere((s) => s.id == id);
  }

  @override
  Future<void> deleteAllSongs() async {
    _songs.clear();
  }

  /// Crée des données d'exemple pour le développement.
  static List<Song> _createSampleData() {
    final now = DateTime.now();
    return [
      // Chant 1: Avec ImageResource (3 images)
      Song(
        id: UuidValue.parse('550e8400-e29b-41d4-a716-446655440001'),
        code: 'ABC123',
        name: 'Chant d\'exemple 1',
        updatedAt: now.subtract(const Duration(days: 10)),
        resources: [
          ImageResource(
            id: UuidValue.parse('550e8400-e29b-41d4-a716-446655440011'),
            name: 'Images du chant 1',
            imagePaths: [
              '/data/user/0/com.example.songbook/files/images/song1_1.jpg',
              '/data/user/0/com.example.songbook/files/images/song1_2.jpg',
              '/data/user/0/com.example.songbook/files/images/song1_3.jpg',
            ],
          ),
        ],
      ),

      // Chant 2: Avec PdfResource
      Song(
        id: UuidValue.parse('550e8400-e29b-41d4-a716-446655440002'),
        code: 'DEF456',
        name: 'Chant d\'exemple 2',
        updatedAt: now.subtract(const Duration(days: 5)),
        resources: [
          PdfResource(
            id: UuidValue.parse('550e8400-e29b-41d4-a716-446655440021'),
            name: 'Partition PDF',
            pdfPath: '/data/user/0/com.example.songbook/files/pdfs/song2.pdf',
          ),
        ],
      ),

      // Chant 3: Avec mix ImageResource + PdfResource
      Song(
        id: UuidValue.parse('550e8400-e29b-41d4-a716-446655440003'),
        code: 'GHI789',
        name: 'Chant d\'exemple 3',
        updatedAt: now.subtract(const Duration(days: 1)),
        resources: [
          ImageResource(
            id: UuidValue.parse('550e8400-e29b-41d4-a716-446655440031'),
            name: 'Images du chant 3',
            imagePaths: [
              '/data/user/0/com.example.songbook/files/images/song3_1.jpg',
              '/data/user/0/com.example.songbook/files/images/song3_2.jpg',
            ],
          ),
          PdfResource(
            id: UuidValue.parse('550e8400-e29b-41d4-a716-446655440032'),
            name: 'Partition PDF du chant 3',
            pdfPath: '/data/user/0/com.example.songbook/files/pdfs/song3.pdf',
          ),
        ],
      ),
    ];
  }
}
