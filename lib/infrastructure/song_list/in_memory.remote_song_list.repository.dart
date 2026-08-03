import 'package:songbook/core/domain/exceptions/song_list_sync.exception.dart';
import 'package:songbook/core/domain/model/share_link.dart';
import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/song_list_snapshot.dart';
import 'package:songbook/core/domain/model/subscription_result.dart';
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

  /// Secrets émis par liste, gardés pour que `share` reste idempotent.
  final Map<String, ({String token, String code})> _shares = {};

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
  Future<SongList> fetchOne(String baseUrl, UuidValue id) async {
    final list = _lists[id.value];
    if (list == null || _deletedIds.contains(id.value)) {
      throw const SongListGoneException();
    }

    return list;
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

  @override
  Future<ShareLink> share(String baseUrl, UuidValue id) async {
    // Idempotent comme le serveur : le lien est permanent, en émettre un
    // nouveau casserait celui déjà transmis.
    final secrets = _shares[id.value] ??= (
      token:
          'DEMO${_shares.length}${id.value.replaceAll('-', '').toUpperCase()}',
      code: 'DEMO${_shares.length.toString().padLeft(4, '0')}',
    );

    return ShareLink(
      token: secrets.token,
      code: secrets.code,
      link: 'https://demo.songbook.local/l/${secrets.token}',
    );
  }

  @override
  Future<SubscriptionResult> subscribe(
    String baseUrl, {
    String? token,
    String? code,
  }) async {
    final listId = _shares.entries
        .where((e) => e.value.token == token || e.value.code == code)
        .map((e) => e.key)
        .firstOrNull;

    final source = listId == null ? null : _lists[listId];
    if (source == null || _deletedIds.contains(listId)) {
      throw const ShareLinkNotFoundException();
    }

    // Le mode démo n'a qu'un utilisateur : tout lien émis ici revient
    // forcément à son auteur. C'est ce que dirait le serveur, et l'app se
    // contentera d'ouvrir la liste au lieu de la dupliquer.
    return SubscriptionResult(
      source: source,
      alreadyOwner: true,
      existingCopyId: null,
    );
  }
}
