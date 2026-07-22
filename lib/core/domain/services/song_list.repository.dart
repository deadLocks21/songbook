import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/upstream_snapshot.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';

/// Interface pour acceder et gerer les listes de chants.
/// Expose les operations de lecture et d'ecriture.
///
/// Le stockage local est la copie de travail : on y ecrit hors-ligne, et un
/// etat de synchro par liste (« modifiee depuis le dernier push », « supprimee,
/// suppression pas encore propagee ») dit ce qu'il reste a envoyer au serveur.
abstract interface class SongListRepository {
  /// Recupere toutes les listes de chants avec leurs entrees.
  /// Exclut les listes supprimees localement dont la suppression n'est pas
  /// encore propagee : pour l'utilisateur, elles n'existent plus.
  Future<List<SongList>> getAllSongLists();

  /// Recupere une liste de chants par son identifiant.
  Future<SongList?> getSongListById(UuidValue id);

  /// Ajoute une nouvelle liste de chants avec ses entrees.
  /// La liste est marquee comme restant a pousser.
  Future<void> addSongList(SongList songList);

  /// Met a jour une liste existante et remplace toutes ses entrees.
  /// La liste est marquee comme restant a pousser.
  Future<void> updateSongList(SongList songList);

  /// Supprime une liste de chants et toutes ses entrees.
  /// Si la liste existe cote serveur, la ligne est conservee en attendant que
  /// la suppression y soit propagee (cf. [getPendingDeletions]).
  Future<void> deleteSongList(UuidValue id);

  /// Listes modifiees localement et pas encore poussees, les plus anciennes
  /// d'abord.
  ///
  /// Chaque element porte la [revision] locale observee : le nombre d'ecritures
  /// faites sur cette liste depuis la derniere synchro. Elle doit etre rendue
  /// telle quelle a [markSynced], qui s'en sert pour ne pas declarer « a jour »
  /// une liste re-modifiee pendant l'envoi.
  Future<List<({SongList list, int revision})>> getPendingPush();

  /// Identifiants des listes supprimees localement dont la suppression n'a pas
  /// encore ete propagee au serveur.
  Future<List<UuidValue>> getPendingDeletions();

  /// Enregistre qu'une liste est desormais alignee sur la [version] du serveur.
  ///
  /// La [revision] est celle rendue par [getPendingPush] au debut de l'envoi.
  /// Si la liste a ete re-modifiee entre-temps, la nouvelle version serveur est
  /// bien retenue — elle servira de base au prochain envoi — mais la liste reste
  /// marquee comme restant a pousser : sans cela, l'edition faite pendant
  /// l'envoi ne serait jamais transmise et un pull finirait par l'ecraser.
  Future<void> markSynced(UuidValue id, int version, {required int revision});

  /// Applique l'etat serveur d'une liste (creation ou remplacement complet).
  ///
  /// N'ecrase jamais une liste modifiee localement : ces modifications-la n'ont
  /// pas encore ete poussees, les perdre serait perdre le travail de
  /// l'utilisateur. Elles repartiront au prochain push.
  Future<void> upsertFromRemote(SongList songList);

  /// Supprime definitivement la ligne locale, une fois la suppression propagee
  /// au serveur.
  Future<void> purge(UuidValue id);

  /// Applique une suppression venue du serveur (liste supprimee depuis un autre
  /// appareil). Comme [upsertFromRemote], respecte les modifications locales non
  /// poussees et laisse la liste en place dans ce cas.
  Future<void> applyRemoteDeletion(UuidValue id);

  /// La copie locale faite depuis [sourceListId], s'il y en a une.
  ///
  /// Permet de rouvrir la copie existante quand le meme lien est utilise deux
  /// fois, au lieu d'en empiler une seconde. Le serveur repond deja la meme
  /// chose ; on le redemande en local pour que le cas marche hors-ligne et pour
  /// les listes pas encore poussees.
  Future<SongList?> findCopyOf(UuidValue sourceListId);

  /// Retient l'etat de la source au dernier tirage, base du futur tirage
  /// assiste. Remplace l'instantane precedent de la meme liste.
  Future<void> saveUpstreamSnapshot(UpstreamSnapshot snapshot);

  /// L'instantane retenu pour [songListId], s'il existe.
  ///
  /// Absent sur un appareil qui a recupere la copie par synchro plutot que par
  /// abonnement : l'instantane est local, il ne transite pas par le serveur.
  Future<UpstreamSnapshot?> getUpstreamSnapshot(UuidValue songListId);
}
