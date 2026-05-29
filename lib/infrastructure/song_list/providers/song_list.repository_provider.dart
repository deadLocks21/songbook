import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/domain/services/song_list.repository.dart';
import 'package:songbook/infrastructure/settings/providers/in_memory_mode.provider.dart';
import 'package:songbook/infrastructure/song_list/drift.song_list.repository.dart';
import 'package:songbook/infrastructure/song_list/in_memory.song_list.repository.dart';

part 'song_list.repository_provider.g.dart';

/// Provider pour l'implementation du SongListRepository.
/// En mémoire en mode démo (web, aucune URL, ou URL « memory »),
/// DriftSongListRepository sinon — cf. [inMemoryModeProvider].
///
/// Comme [songRepository], l'implémentation en mémoire conserve son état en
/// instance : on épingle le provider (`ref.keepAlive`) en mode démo pour ne pas
/// le perdre à l'auto-dispose (Drift, lui, persiste sur disque).
@riverpod
SongListRepository songListRepository(Ref ref) {
  if (ref.watch(inMemoryModeProvider)) {
    ref.keepAlive();
    return InMemorySongListRepository();
  }
  return const DriftSongListRepository();
}
