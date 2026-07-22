import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/core/domain/model/upstream_state.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';

part 'upstream_states.provider.g.dart';

/// Où en sont les sources suivies, d'après la dernière synchro.
///
/// Volontairement **en mémoire** : l'app se synchronise au démarrage, donc
/// conserver cet état d'une session à l'autre ne ferait que ressortir une
/// information périmée — un badge « mise à jour disponible » pour un tirage
/// déjà fait ailleurs.
@Riverpod(keepAlive: true)
class UpstreamStates extends _$UpstreamStates {
  @override
  Map<UuidValue, UpstreamState> build() => const {};

  void record(List<UpstreamState> states) {
    state = {for (final s in states) s.sourceListId: s};
  }

  /// Cette liste a-t-elle quelque chose à tirer de sa source ?
  ///
  /// Faux tant que rien n'est connu : mieux vaut ne rien annoncer que promettre
  /// une mise à jour qui n'existe pas.
  bool hasUpdateFor(SongListDto songList) {
    final sourceListId = songList.sourceListId;
    final sourceVersion = songList.sourceVersion;
    if (sourceListId == null || sourceVersion == null) return false;

    return state[UuidValue.parse(sourceListId)]?.hasNewsFor(sourceVersion) ??
        false;
  }

  /// La source de cette liste a-t-elle disparu ?
  bool isOrphan(SongListDto songList) {
    final sourceListId = songList.sourceListId;
    if (sourceListId == null) return false;

    return state[UuidValue.parse(sourceListId)]?.deleted ?? false;
  }
}
