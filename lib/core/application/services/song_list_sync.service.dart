import 'package:songbook/core/domain/exceptions/song_list_sync.exception.dart';
import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/services/remote_song_list.repository.dart';
import 'package:songbook/core/domain/services/song_list.repository.dart';

/// Synchronisation **bidirectionnelle** des listes de chants entre l'appareil
/// et le serveur, pour les listes de l'utilisateur connecté.
///
/// Distinct de [SyncService], qui ne fait que descendre le catalogue des
/// chants : ici les écritures vont dans les deux sens, et l'utilisateur est
/// seul à écrire ses propres listes depuis plusieurs appareils.
///
/// L'ordre compte : on **pousse d'abord**, on tire ensuite. Un push d'abord
/// garantit que le travail fait hors-ligne existe côté serveur avant qu'on ne
/// compare quoi que ce soit — sans quoi le pull prendrait des décisions
/// (« cette liste a disparu ») en ignorant des modifications locales qui n'ont
/// jamais eu leur chance.
class SongListSyncService {
  final SongListRepository _local;
  final RemoteSongListRepository _remote;

  const SongListSyncService(this._local, this._remote);

  /// Pousse les changements locaux puis récupère l'état du serveur.
  Future<void> sync(String baseUrl) async {
    await push(baseUrl);
    await _pull(baseUrl);
  }

  /// Envoie au serveur ce qui n'y est pas encore : suppressions d'abord,
  /// créations et mises à jour ensuite.
  ///
  /// Les suppressions passent en premier pour que la place soit nette avant les
  /// écritures — une liste supprimée puis recréée avec le même identifiant se
  /// comporte alors comme une vraie recréation.
  Future<void> push(String baseUrl) async {
    for (final id in await _local.getPendingDeletions()) {
      await _remote.delete(baseUrl, id);
      await _local.purge(id);
    }

    for (final pending in await _local.getPendingPush()) {
      final version = await _pushOne(baseUrl, pending.list);
      await _local.markSynced(
        pending.list.id,
        version,
        revision: pending.revision,
      );
    }
  }

  Future<int> _pushOne(String baseUrl, SongList songList) async {
    if (songList.version == null) {
      return _remote.create(baseUrl, songList);
    }

    try {
      return await _remote.update(baseUrl, songList);
    } on SongListVersionConflictException catch (conflict) {
      // Le canon a bougé depuis un autre appareil. L'utilisateur est seul
      // à écrire ses listes : plutôt que d'imposer un arbitrage qu'il ne
      // pourrait pas rendre ici, on rejoue son édition la plus récente sur la
      // version courante.
      return _remote.update(
        baseUrl,
        songList.copyWith(version: conflict.currentVersion),
      );
    } on SongListGoneException {
      // Supprimée depuis un autre appareil pendant qu'on l'éditait ici. On la
      // renvoie comme une création — le serveur la ressuscite — plutôt que
      // d'abandonner une modification que l'utilisateur croit enregistrée.
      return _remote.create(baseUrl, songList);
    }
  }

  /// Aligne la base locale sur le serveur, sans jamais écraser une modification
  /// locale en attente de push (le repository fait respecter cette règle).
  Future<void> _pull(String baseUrl) async {
    final snapshot = await _remote.fetchAll(baseUrl);

    for (final songList in snapshot.lists) {
      await _local.upsertFromRemote(songList);
    }

    for (final id in snapshot.deletedIds) {
      await _local.applyRemoteDeletion(id);
    }
  }
}
