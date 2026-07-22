import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/upstream_state.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';

/// Photo de l'etat serveur des listes d'un utilisateur.
///
/// [deletedIds] est indispensable : une liste absente de [lists] peut aussi bien
/// avoir ete supprimee depuis un autre appareil que venir d'etre creee ici sans
/// avoir encore ete poussee. Le serveur tranche en nommant explicitement ce
/// qu'il a supprime.
///
/// [upstream] dit ou en sont les sources suivies, pour que l'app sache quelles
/// copies ont quelque chose a tirer sans interroger chaque source.
class SongListSnapshot {
  final List<SongList> lists;
  final List<UuidValue> deletedIds;
  final List<UpstreamState> upstream;

  const SongListSnapshot({
    required this.lists,
    required this.deletedIds,
    this.upstream = const [],
  });

  /// L'etat de la source suivie par une copie, s'il est connu.
  UpstreamState? stateOf(UuidValue sourceListId) {
    for (final state in upstream) {
      if (state.sourceListId == sourceListId) return state;
    }
    return null;
  }
}
