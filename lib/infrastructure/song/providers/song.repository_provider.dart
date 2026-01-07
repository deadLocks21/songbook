import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/domain/services/song.repository.dart';
import 'package:songbook/infrastructure/song/drift/drift.song.repository.dart';
import 'package:songbook/infrastructure/song/in_memory.song.repository.dart';

part 'song.repository_provider.g.dart';

/// Provider pour l'implémentation du SongRepository.
/// En développement/debug: utilise InMemorySongRepository avec données d'exemple.
/// En production: utilise DriftSongRepository avec la base de données SQLite.
@riverpod
SongRepository songRepository(Ref ref) {
  // En mode debug/développement, utilise l'implémentation en mémoire
  if (kDebugMode) {
    return InMemorySongRepository();
  }

  // En production, utilise Drift
  return DriftSongRepository();
}
