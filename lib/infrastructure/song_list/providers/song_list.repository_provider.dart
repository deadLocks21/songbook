import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/domain/services/song_list.repository.dart';
import 'package:songbook/infrastructure/song_list/drift.song_list.repository.dart';
import 'package:songbook/infrastructure/song_list/in_memory.song_list.repository.dart';

part 'song_list.repository_provider.g.dart';

/// Provider pour l'implementation du SongListRepository.
/// Utilise InMemorySongListRepository sur le web, DriftSongListRepository sinon.
@riverpod
SongListRepository songListRepository(Ref ref) {
  if (kIsWeb) {
    return InMemorySongListRepository();
  }
  return const DriftSongListRepository();
}
