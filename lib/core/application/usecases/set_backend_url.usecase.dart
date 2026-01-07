import 'package:songbook/core/domain/services/settings.repository.dart';

/// Cas d'usage pour définir l'URL du backend
class SetBackendUrlUseCase {
  final SettingsRepository _settingsRepository;

  SetBackendUrlUseCase(this._settingsRepository);

  /// Exécute le cas d'usage pour définir l'URL du backend
  Future<void> execute(String url) async {
    await _settingsRepository.setBackendUrl(url);
  }
}
