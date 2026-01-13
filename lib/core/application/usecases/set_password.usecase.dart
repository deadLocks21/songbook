import 'package:songbook/core/domain/services/settings.repository.dart';

/// Use case pour stocker le mot de passe d'authentification API.
class SetPasswordUseCase {
  final SettingsRepository _settingsRepository;

  SetPasswordUseCase(this._settingsRepository);

  /// Exécute le stockage du mot de passe.
  ///
  /// [password] le mot de passe à stocker de manière sécurisée.
  Future<void> execute(String password) async {
    await _settingsRepository.setPassword(password);
  }
}
