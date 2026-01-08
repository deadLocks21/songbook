import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/domain/services/song.repository.dart';
import 'package:songbook/infrastructure/song/drift/drift.song.repository.dart';

part 'song.repository_provider.g.dart';

/// Provider pour l'implémentation du SongRepository.
@riverpod
SongRepository songRepository(Ref ref) {
  return DriftSongRepository();
}
