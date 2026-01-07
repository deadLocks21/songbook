/// Interface pour la gestion de la persistance des paramètres de l'application
abstract interface class SettingsRepository {
  /// Récupère l'URL du backend actuellement sauvegardée
  ///
  /// Retourne une URL par défaut si aucune URL personnalisée n'est configurée
  Future<String> getBackendUrl();

  /// Sauvegarde l'URL du backend configurée par l'utilisateur
  Future<void> setBackendUrl(String url);
}
