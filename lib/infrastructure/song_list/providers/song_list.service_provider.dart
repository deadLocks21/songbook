import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/core/application/services/setlist.service.dart';
import 'package:songbook/infrastructure/song/providers/song.repository_provider.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list.repository_provider.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list_sync.provider.dart';

part 'song_list.service_provider.g.dart';

@riverpod
SetlistService setlistService(Ref ref) {
  final songListRepo = ref.watch(songListRepositoryProvider);
  final songRepo = ref.watch(songRepositoryProvider);
  return SetlistService(
    songListRepo,
    songRepo,
    // Envoi en arrière-plan, jamais attendu : l'enregistrement local est déjà
    // acquis et ne doit pas dépendre du réseau. Le notifier avale et trace ses
    // propres erreurs, et ce qui échoue repartira à la synchro suivante.
    onLocalChange: () =>
        unawaited(ref.read(songListSyncProvider.notifier).push()),
  );
}

@riverpod
Future<List<SongListDto>> songLists(Ref ref) async {
  final service = ref.watch(setlistServiceProvider);
  return service.getAllSetlists();
}
