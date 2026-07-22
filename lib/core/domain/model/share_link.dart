/// Les deux façons équivalentes de donner accès à une liste : un lien à
/// envoyer, un code à dicter.
///
/// Les deux ouvrent le même droit — lire la liste et la copier — et aucun
/// n'ouvre la moindre écriture. Ils sont **permanents** : redemander un partage
/// rend les mêmes, pour ne pas casser ce qui a déjà été transmis.
class ShareLink {
  /// Le secret porté par le lien. Long, jamais lu par un humain.
  final String token;

  /// Le secret qu'on tape. Court, sans les lettres qui se lisent comme des
  /// chiffres ; la casse et les espaces sont sans importance à la saisie.
  final String code;

  /// L'URL complète à partager, construite par le serveur à partir de sa propre
  /// adresse — donc toujours celle de l'instance qu'on interroge.
  final String link;

  const ShareLink({
    required this.token,
    required this.code,
    required this.link,
  });
}
