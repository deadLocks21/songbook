import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/domain/services/song.repository.dart';
import 'package:songbook/infrastructure/song/drift/drift.song.repository.dart';
import 'package:songbook/infrastructure/song/in_memory.song.repository.dart';

part 'song.repository_provider.g.dart';

/// Provider pour l'implémentation du SongRepository.
/// Utilise InMemorySongRepository sur le web, DriftSongRepository sinon.
@riverpod
SongRepository songRepository(Ref ref) {
  if (kIsWeb) {
    return InMemorySongRepository();
  }
  return const DriftSongRepository();
}
