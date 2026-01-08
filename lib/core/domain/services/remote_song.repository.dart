import 'package:songbook/core/domain/model/remote_song.dart';

/// Interface pour récupérer les songs depuis une source distante.
abstract interface class RemoteSongRepository {
  /// Récupère tous les songs depuis l'URL de base spécifiée.
  /// [baseUrl] est l'URL de l'API distante.
  Future<List<RemoteSong>> fetchSongs(String baseUrl);
}
