import 'package:songbook/core/domain/exceptions/song_list_sync.exception.dart';
import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/song_list_snapshot.dart';
import 'package:songbook/core/domain/model/upstream_snapshot.dart';
import 'package:songbook/core/domain/model/upstream_state.dart';
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

  /// Appelé à chaque pull avec l'état des sources suivies.
  ///
  /// C'est la seule occasion de le savoir : cet état n'est pas stocké en local,
  /// et il n'a pas à l'être — l'app se synchronise au démarrage, donc le
  /// conserver d'une session à l'autre ne ferait que ressortir une information
  /// périmée.
  final void Function(List<UpstreamState> states)? _onUpstreamStates;

  const SongListSyncService(
    this._local,
    this._remote, {
    void Function(List<UpstreamState> states)? onUpstreamStates,
  }) : _onUpstreamStates = onUpstreamStates;

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

    await _captureMissingBaselines(baseUrl, snapshot);

    _onUpstreamStates?.call(snapshot.upstream);
  }

  /// Saisit l'instantané de base là où il manque, tant que la source n'a pas
  /// bougé.
  ///
  /// L'instantané est local et ne transite pas par le serveur : un appareil qui
  /// a reçu une copie par synchro plutôt que par abonnement n'en a pas, et ne
  /// pourrait produire qu'une comparaison approchée. Mais tant que l'amont est
  /// resté où la copie l'a laissé, la source **est** la base par définition. On
  /// la saisit au passage, une fois, et cet appareil retrouve un tirage exact
  /// pour la suite.
  ///
  /// Silencieux et sans conséquence s'il échoue : au pire l'appareil garde sa
  /// comparaison approchée, qu'il annonce comme telle.
  Future<void> _captureMissingBaselines(
    String baseUrl,
    SongListSnapshot snapshot,
  ) async {
    for (final songList in await _local.getAllSongLists()) {
      final upstream = songList.upstream;
      if (upstream == null) continue;
      if (await _local.getUpstreamSnapshot(songList.id) != null) continue;

      final state = snapshot.stateOf(upstream.sourceListId);
      if (state == null ||
          state.deleted ||
          state.version != upstream.sourceVersion) {
        continue;
      }

      try {
        final source = await _remote.fetchOne(baseUrl, upstream.sourceListId);
        await _local.saveUpstreamSnapshot(
          UpstreamSnapshot.of(songList.id, source),
        );
      } on SongListGoneException {
        // Plus lisible depuis cet appareil : rien à saisir, le tirage le dira
        // le moment venu.
      }
    }
  }
}
