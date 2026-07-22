import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';

/// Photo de l'etat serveur des listes d'un utilisateur.
///
/// [deletedIds] est indispensable : une liste absente de [lists] peut aussi bien
/// avoir ete supprimee depuis un autre appareil que venir d'etre creee ici sans
/// avoir encore ete poussee. Le serveur tranche en nommant explicitement ce
/// qu'il a supprime.
class SongListSnapshot {
  final List<SongList> lists;
  final List<UuidValue> deletedIds;

  const SongListSnapshot({required this.lists, required this.deletedIds});
}
