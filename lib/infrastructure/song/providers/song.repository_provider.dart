import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/domain/services/song.repository.dart';
import 'package:songbook/infrastructure/settings/providers/in_memory_mode.provider.dart';
import 'package:songbook/infrastructure/song/drift/drift.song.repository.dart';
import 'package:songbook/infrastructure/song/in_memory.song.repository.dart';

part 'song.repository_provider.g.dart';

/// Provider pour l'implémentation du SongRepository.
/// En mémoire en mode démo (web, aucune URL, ou URL « memory »),
/// DriftSongRepository sinon — cf. [inMemoryModeProvider].
///
/// En mode démo, [InMemorySongRepository] garde les chants dans un champ
/// d'instance : on **épingle** alors le provider (`ref.keepAlive`) pour que
/// l'auto-dispose ne recrée pas une instance vide entre la synchro et l'accueil
/// (sinon : chants perdus « count=0 » et re-synchros en boucle). Drift persiste
/// sur disque, donc seul l'in-memory a besoin de cette épingle.
@riverpod
SongRepository songRepository(Ref ref) {
  if (ref.watch(inMemoryModeProvider)) {
    ref.keepAlive();
    return InMemorySongRepository();
  }
  return const DriftSongRepository();
}
