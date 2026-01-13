import 'package:songbook/core/domain/services/settings.repository.dart';

/// Cas d'usage pour définir l'URL du backend
class SetBackendUrlUseCase {
  final SettingsRepository _settingsRepository;

  SetBackendUrlUseCase(this._settingsRepository);

  /// Exécute le cas d'usage pour définir l'URL du backend.
  ///
  /// Supprime également le mot de passe stocké car celui-ci
  /// est lié à l'ancien serveur et ne sera probablement pas valide
  /// pour le nouveau serveur.
  Future<void> execute(String url) async {
    // Supprimer le mot de passe stocké car l'URL du serveur a changé
    await _settingsRepository.clearPassword();

    // Sauvegarder la nouvelle URL
    await _settingsRepository.setBackendUrl(url);
  }
}
