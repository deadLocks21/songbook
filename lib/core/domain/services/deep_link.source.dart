/// Les URL que le système fait remonter à l'app.
///
/// Deux moments, et il faut les deux : le lien qui a **démarré** l'app depuis
/// zéro, et ceux qui arrivent pendant qu'elle tourne déjà. N'écouter que le
/// flux raterait le cas le plus courant — quelqu'un qui clique un lien sans
/// avoir l'app ouverte.
///
/// Interface pour que la logique de traitement se teste sans plugin natif.
abstract interface class DeepLinkSource {
  /// L'URL ayant lancé l'app, ou `null` si elle a démarré normalement.
  /// Ne rend le lien qu'**une fois** : le rejouer relancerait un abonnement
  /// déjà traité à chaque redémarrage du gestionnaire.
  Future<Uri?> initialLink();

  /// Les URL reçues app déjà ouverte.
  Stream<Uri> linkStream();
}
