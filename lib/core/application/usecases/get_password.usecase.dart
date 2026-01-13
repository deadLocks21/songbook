import 'package:songbook/core/domain/services/settings.repository.dart';

/// Use case pour récupérer le mot de passe d'authentification API stocké.
class GetPasswordUseCase {
  final SettingsRepository _settingsRepository;

  GetPasswordUseCase(this._settingsRepository);

  /// Exécute la récupération du mot de passe.
  ///
  /// Retourne le mot de passe stocké ou null si aucun mot de passe n'est stocké.
  Future<String?> execute() async {
    return await _settingsRepository.getPassword();
  }
}
