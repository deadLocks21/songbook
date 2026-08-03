import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/core/application/services/setlist.service.dart';
import 'package:songbook/core/application/services/song_schedule.service.dart';
import 'package:songbook/core/domain/model/song_schedule.dart';
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

/// L'historique de programmation de chaque chant, par identifiant de chant.
///
/// Dérivé des listes déjà chargées : rien de plus à lire en base, et tout ce qui
/// les fait bouger — un enregistrement, une synchro — rafraîchit l'historique
/// par la même occasion.
///
/// [excludingListId] est l'identifiant de la liste en cours d'édition, qui ne
/// doit pas se compter elle-même (cf. [SongScheduleService.bySongId]).
@riverpod
Future<Map<String, SongSchedule>> songSchedules(
  Ref ref, {
  String? excludingListId,
}) async {
  final setlists = await ref.watch(songListsProvider.future);
  return const SongScheduleService().bySongId(
    setlists,
    now: DateTime.now(),
    excludingListId: excludingListId,
  );
}
