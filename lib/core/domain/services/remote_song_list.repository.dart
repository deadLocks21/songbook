import 'package:songbook/core/domain/model/share_link.dart';
import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/song_list_snapshot.dart';
import 'package:songbook/core/domain/model/subscription_result.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';

/// Acces aux listes de chants stockees sur le serveur, pour le compte de
/// l'utilisateur connecte.
///
/// Les ecritures renvoient la version du canon apres coup : c'est elle que
/// l'appareil doit retenir pour pouvoir editer la liste la fois suivante.
abstract interface class RemoteSongListRepository {
  /// Toutes les listes de l'utilisateur, plus les identifiants de celles qu'il
  /// a supprimees depuis n'importe lequel de ses appareils.
  Future<SongListSnapshot> fetchAll(String baseUrl);

  /// Premier envoi d'une liste : l'identifiant est celui genere localement.
  /// Rejouable — reenvoyer la meme liste reapplique son contenu.
  Future<int> create(String baseUrl, SongList songList);

  /// Envoi d'une nouvelle version d'une liste deja connue du serveur.
  ///
  /// Leve [SongListVersionConflictException] si `songList.version` n'est plus la
  /// version courante du canon.
  Future<int> update(String baseUrl, SongList songList);

  /// Supprime la liste cote serveur. Rejouable.
  Future<void> delete(String baseUrl, UuidValue id);

  /// Ouvre une liste aux abonnements et rend de quoi la partager.
  ///
  /// Idempotent : rappeler rend les memes secrets, sinon le lien deja envoye
  /// cesserait de fonctionner. Reserve au proprietaire de la liste.
  Future<ShareLink> share(String baseUrl, UuidValue id);

  /// Echange un [token] (venu d'un lien) **ou** un [code] (tape a la main)
  /// contre le droit de lire la liste, et recupere celle-ci en entier.
  ///
  /// Leve [ShareLinkNotFoundException] si le secret ne mene a rien.
  Future<SubscriptionResult> subscribe(
    String baseUrl, {
    String? token,
    String? code,
  });
}
