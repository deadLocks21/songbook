import 'package:songbook/core/domain/exceptions/song_list_sync.exception.dart';
import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/song_list_snapshot.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/remote_song_list.repository.dart';

/// Implémentation du RemoteSongListRepository en mémoire.
///
/// Sert le mode démo (web, aucune URL, ou URL « memory ») et les tests : elle
/// rejoue les règles du serveur — versions incrémentées à chaque écriture,
/// conflit sur version périmée, suppressions conservées comme pierres
/// tombales — pour que la synchro se comporte comme en vrai, sans réseau.
class InMemoryRemoteSongListRepository implements RemoteSongListRepository {
  final Map<String, SongList> _lists = {};
  final Set<String> _deletedIds = {};

  @override
  Future<SongListSnapshot> fetchAll(String baseUrl) async {
    return SongListSnapshot(
      lists: _lists.values
          .where((l) => !_deletedIds.contains(l.id.value))
          .toList(),
      deletedIds: _deletedIds.map(UuidValue.parse).toList(),
    );
  }

  @override
  Future<int> create(String baseUrl, SongList songList) async {
    // Renvoyer une liste déjà connue réapplique son contenu : c'est ce qui rend
    // l'envoi rejouable, et ce qui ressuscite une liste supprimée.
    final existing = _lists[songList.id.value];
    final version = (existing?.version ?? 0) + 1;

    _lists[songList.id.value] = songList.copyWith(version: version);
    _deletedIds.remove(songList.id.value);

    return version;
  }

  @override
  Future<int> update(String baseUrl, SongList songList) async {
    final existing = _lists[songList.id.value];
    // Inconnue ou supprimée : comme l'API, qui répond 404 sur une pierre
    // tombale et réserve la résurrection à la création.
    if (existing == null || _deletedIds.contains(songList.id.value)) {
      throw const SongListGoneException();
    }

    final currentVersion = existing.version ?? 1;
    if (songList.version != currentVersion) {
      throw SongListVersionConflictException(currentVersion);
    }

    final version = currentVersion + 1;
    _lists[songList.id.value] = songList.copyWith(version: version);

    return version;
  }

  @override
  Future<void> delete(String baseUrl, UuidValue id) async {
    // La ligne reste : c'est elle qui portera la pierre tombale renvoyée aux
    // autres appareils.
    _deletedIds.add(id.value);
  }
}
