import 'package:songbook/core/domain/model/share_link.dart';
import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/upstream_snapshot.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/remote_song_list.repository.dart';
import 'package:songbook/core/domain/services/song_list.repository.dart';

/// Ce qu'il est advenu d'un lien ou d'un code échangé.
enum FollowStatus {
  /// Une copie vient d'être créée ici.
  copied,

  /// Le lien est revenu à son auteur : rien à copier, la liste est déjà à lui.
  alreadyOwner,

  /// Cette source était déjà suivie. Aucune seconde copie n'est créée.
  alreadyFollowing,
}

/// Le résultat d'un abonnement, du point de vue de l'écran qui l'a demandé.
class FollowOutcome {
  final FollowStatus status;

  /// La liste à ouvrir. `null` quand la copie existe côté serveur mais pas
  /// encore ici — elle arrivera à la prochaine synchro, et l'ouvrir maintenant
  /// mènerait à un écran vide.
  final UuidValue? listId;

  const FollowOutcome(this.status, this.listId);
}

/// Partage d'une liste, et abonnement à celle de quelqu'un d'autre.
///
/// S'abonner **duplique** : on repart avec une liste à soi, librement
/// modifiable, qui retient d'où elle vient. Rien ne remonte jamais vers la
/// source — l'auteur n'est pas affecté, et n'a pas à savoir qu'on la suit.
class SongListSharingService {
  final SongListRepository _local;
  final RemoteSongListRepository _remote;

  const SongListSharingService(this._local, this._remote);

  /// Ouvre une liste aux abonnements et rend de quoi la transmettre.
  ///
  /// La liste doit exister côté serveur : une liste créée hors ligne et jamais
  /// poussée n'a rien à partager. L'appelant s'assure du push au préalable.
  Future<ShareLink> share(String baseUrl, UuidValue listId) =>
      _remote.share(baseUrl, listId);

  /// Échange un [token] (venu d'un lien) ou un [code] (tapé) contre une copie
  /// locale de la liste.
  Future<FollowOutcome> follow(
    String baseUrl, {
    String? token,
    String? code,
  }) async {
    final result = await _remote.subscribe(baseUrl, token: token, code: code);
    final source = result.source;

    // Son propre lien : dupliquer laisserait l'utilisateur avec deux fois la
    // même liste. On ouvre l'originale.
    if (result.alreadyOwner) {
      return FollowOutcome(FollowStatus.alreadyOwner, source.id);
    }

    // La copie locale fait foi sur « est-ce que je l'ai déjà ici ? » : elle
    // répond même pour une copie créée hors ligne et pas encore poussée, que
    // le serveur ne peut pas connaître.
    final localCopy = await _local.findCopyOf(source.id);
    if (localCopy != null) {
      return FollowOutcome(FollowStatus.alreadyFollowing, localCopy.id);
    }

    // Le serveur en connaît une, faite depuis un autre appareil. En créer une
    // seconde laisserait l'utilisateur avec deux copies de la même source dès
    // la synchro suivante.
    if (result.existingCopyId != null) {
      return const FollowOutcome(FollowStatus.alreadyFollowing, null);
    }

    final copy = SongList.copyOf(source);
    await _local.addSongList(copy);

    // L'instantané se prend maintenant ou jamais : dès la première
    // modification de la copie, on ne saurait plus reconstituer l'état de la
    // source au moment où on l'a prise.
    await _local.saveUpstreamSnapshot(UpstreamSnapshot.of(copy.id, source));

    return FollowOutcome(FollowStatus.copied, copy.id);
  }
}
