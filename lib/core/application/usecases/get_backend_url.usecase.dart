import 'package:songbook/core/domain/services/settings.repository.dart';

/// Cas d'usage pour récupérer l'URL du backend
class GetBackendUrlUseCase {
  final SettingsRepository _settingsRepository;

  GetBackendUrlUseCase(this._settingsRepository);

  /// Exécute le cas d'usage pour récupérer l'URL du backend
  Future<String?> execute() async {
    return await _settingsRepository.getBackendUrl();
  }
}
