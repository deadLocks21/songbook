import 'package:songbook/core/domain/model/remote_song.dart';

/// Interface pour récupérer les songs depuis une source distante.
abstract interface class RemoteSongRepository {
  /// Récupère les songs depuis l'URL de base spécifiée.
  ///
  /// [baseUrl] est l'URL de l'API distante. Si [recueils] est non vide, seul
  /// les chants appartenant à l'un de ces codes de recueil sont renvoyés
  /// (union/OR, cf. `/api/songs?recueils=...`). Vide = tous les chants.
  Future<List<RemoteSong>> fetchSongs(
    String baseUrl, {
    List<String> recueils = const [],
  });
}
