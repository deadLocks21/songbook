/// Interface pour la gestion de la persistance des paramètres de l'application
abstract interface class SettingsRepository {
  /// Récupère l'URL du backend actuellement sauvegardée
  ///
  /// Retourne une URL par défaut si aucune URL personnalisée n'est configurée
  Future<String> getBackendUrl();

  /// Sauvegarde l'URL du backend configurée par l'utilisateur
  Future<void> setBackendUrl(String url);

  /// Récupère le mot de passe stocké pour l'authentification API.
  /// Retourne null si aucun mot de passe n'est stocké.
  Future<String?> getPassword();

  /// Stocke le mot de passe pour l'authentification API.
  Future<void> setPassword(String password);

  /// Supprime le mot de passe stocké.
  Future<void> clearPassword();

  /// Récupère le répertoire de synchronisation personnalisé.
  /// Retourne null si l'emplacement par défaut est utilisé.
  Future<String?> getSyncDirectory();

  /// Définit le répertoire de synchronisation personnalisé.
  /// Passer null pour revenir à l'emplacement par défaut.
  Future<void> setSyncDirectory(String? path);
}
