import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/upstream_snapshot.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/song_list.repository.dart';

/// Implémentation en mémoire du SongListRepository.
/// Utilisé pour le web et les tests.
///
/// L'état de synchro est suivi comme dans l'implémentation SQLite, pour que le
/// service de synchro se comporte identiquement des deux côtés.
class InMemorySongListRepository implements SongListRepository {
  final List<SongList> _songLists;

  /// Nombre d'écritures locales en attente d'envoi, par identifiant de liste
  /// (cf. `dirty` dans l'implémentation SQLite).
  final Map<String, int> _pendingWrites;
  final Set<String> _pendingDeletion;

  /// État de la source au dernier tirage, par identifiant de copie.
  final Map<String, UpstreamSnapshot> _upstreamSnapshots;

  InMemorySongListRepository()
    : _songLists = [],
      _pendingWrites = {},
      _pendingDeletion = {},
      _upstreamSnapshots = {};

  @override
  Future<List<SongList>> getAllSongLists() async {
    return List.unmodifiable(
      _songLists.where((s) => !_pendingDeletion.contains(s.id.value)),
    );
  }

  @override
  Future<SongList?> getSongListById(UuidValue id) async {
    if (_pendingDeletion.contains(id.value)) return null;
    final index = _indexOf(id);
    return index == -1 ? null : _songLists[index];
  }

  @override
  Future<void> addSongList(SongList songList) async {
    _songLists.add(songList);
    _touch(songList.id);
  }

  @override
  Future<void> updateSongList(SongList songList) async {
    final index = _indexOf(songList.id);
    if (index != -1) {
      _songLists[index] = songList;
      _touch(songList.id);
    }
  }

  @override
  Future<void> deleteSongList(UuidValue id) async {
    final index = _indexOf(id);
    // Jamais poussée : rien à propager, on efface directement.
    if (index == -1 || _songLists[index].version == null) {
      await purge(id);
      return;
    }

    _pendingDeletion.add(id.value);
    _pendingWrites.remove(id.value);
  }

  @override
  Future<List<({SongList list, int revision})>> getPendingPush() async {
    return _songLists
        .where((s) => _hasLocalChanges(s.id))
        .map((s) => (list: s, revision: _pendingWrites[s.id.value]!))
        .toList();
  }

  @override
  Future<List<UuidValue>> getPendingDeletions() async {
    return _pendingDeletion.map(UuidValue.parse).toList();
  }

  @override
  Future<void> markSynced(
    UuidValue id,
    int version, {
    required int revision,
  }) async {
    final index = _indexOf(id);
    if (index != -1) {
      _songLists[index] = _songLists[index].copyWith(version: version);
    }
    // Re-modifiée pendant l'envoi : la version serveur est acquise, mais il
    // reste à pousser ce qui a été écrit entre-temps.
    if (_pendingWrites[id.value] == revision) {
      _pendingWrites.remove(id.value);
    }
  }

  @override
  Future<void> upsertFromRemote(SongList songList) async {
    if (_hasLocalChanges(songList.id)) return;

    final index = _indexOf(songList.id);
    if (index == -1) {
      _songLists.add(songList);
    } else {
      _songLists[index] = songList;
    }
    _pendingWrites.remove(songList.id.value);
    _pendingDeletion.remove(songList.id.value);
  }

  @override
  Future<void> purge(UuidValue id) async {
    _songLists.removeWhere((s) => s.id == id);
    _pendingWrites.remove(id.value);
    _pendingDeletion.remove(id.value);
    _upstreamSnapshots.remove(id.value);
  }

  @override
  Future<void> applyRemoteDeletion(UuidValue id) async {
    if (_hasLocalChanges(id)) return;
    await purge(id);
  }

  @override
  Future<SongList?> findCopyOf(UuidValue sourceListId) async {
    return _songLists
        .where(
          (s) =>
              s.upstream?.sourceListId == sourceListId &&
              !_pendingDeletion.contains(s.id.value),
        )
        .firstOrNull;
  }

  @override
  Future<void> saveUpstreamSnapshot(UpstreamSnapshot snapshot) async {
    _upstreamSnapshots[snapshot.songListId.value] = snapshot;
  }

  @override
  Future<UpstreamSnapshot?> getUpstreamSnapshot(UuidValue songListId) async {
    return _upstreamSnapshots[songListId.value];
  }

  bool _hasLocalChanges(UuidValue id) =>
      (_pendingWrites[id.value] ?? 0) > 0 &&
      !_pendingDeletion.contains(id.value);

  void _touch(UuidValue id) {
    _pendingWrites[id.value] = (_pendingWrites[id.value] ?? 0) + 1;
  }

  int _indexOf(UuidValue id) => _songLists.indexWhere((s) => s.id == id);
}
