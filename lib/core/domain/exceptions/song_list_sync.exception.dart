/// Levee quand le serveur refuse une ecriture parce que la liste a change
/// entre-temps : la version sur laquelle l'edition locale se basait n'est plus
/// la version courante du canon.
///
/// [currentVersion] permet de rejouer l'edition sur la bonne base sans refaire
/// un aller-retour de lecture.
class SongListVersionConflictException implements Exception {
  final int currentVersion;

  const SongListVersionConflictException(this.currentVersion);

  @override
  String toString() =>
      'SongListVersionConflictException: version courante $currentVersion';
}

/// Levee quand le serveur ne connait plus la liste qu'on essaie de mettre a
/// jour : elle a ete supprimee depuis un autre appareil.
///
/// Ce n'est pas une impasse : l'edition faite ici n'a pas encore ete vue par le
/// serveur, et la renvoyer comme une creation ressuscite la liste. Sans cela,
/// une modification hors-ligne serait perdue au profit d'une suppression que
/// l'utilisateur a decidee avant de la faire.
class SongListGoneException implements Exception {
  const SongListGoneException();

  @override
  String toString() => 'SongListGoneException: liste absente du serveur';
}

/// Levee quand un lien ou un code de partage ne mene a rien : jamais emis, mal
/// recopie, ou pointant une liste supprimee depuis.
///
/// Les trois cas sont indistinguables volontairement cote serveur — les
/// separer confirmerait qu'un code donne a deja ete valide.
class ShareLinkNotFoundException implements Exception {
  const ShareLinkNotFoundException();

  @override
  String toString() => 'ShareLinkNotFoundException: lien de partage inconnu';
}
