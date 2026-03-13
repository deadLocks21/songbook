import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/domain/services/song_list.repository.dart';
import 'package:songbook/infrastructure/song_list/drift.song_list.repository.dart';

part 'song_list.repository_provider.g.dart';

/// Provider pour l'implementation du SongListRepository.
@riverpod
SongListRepository songListRepository(Ref ref) {
  return const DriftSongListRepository();
}
