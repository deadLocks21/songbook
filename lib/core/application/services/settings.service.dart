import 'package:songbook/core/application/usecases/set_sync_directory.usecase.dart';
import 'package:songbook/core/domain/model/theme_mode.dart';
import 'package:songbook/core/domain/services/settings.repository.dart';
import 'package:songbook/core/domain/services/theme.repository.dart';

class SettingsService {
  final SettingsRepository _settingsRepository;
  final ThemeRepository _themeRepository;
  final SetSyncDirectoryUseCase _setSyncDirectoryUseCase;

  SettingsService(this._settingsRepository, this._themeRepository)
      : _setSyncDirectoryUseCase =
            SetSyncDirectoryUseCase(_settingsRepository);

  Future<String> getBackendUrl() => _settingsRepository.getBackendUrl();

  Future<void> setBackendUrl(String url) async {
    // Supprimer le mot de passe stocké car l'URL du serveur a changé.
    // Non-bloquant : si le Keychain échoue, on sauvegarde quand même l'URL.
    try {
      await _settingsRepository.clearPassword();
    } catch (_) {
      // Ignorer les erreurs Keychain (ex: entitlement manquant sur macOS)
    }
    await _settingsRepository.setBackendUrl(url);
  }

  Future<String?> getPassword() => _settingsRepository.getPassword();

  Future<void> setPassword(String password) =>
      _settingsRepository.setPassword(password);

  Future<String?> getSyncDirectory() => _settingsRepository.getSyncDirectory();

  Future<void> setSyncDirectory(String? path,
          {void Function(double)? onProgress}) =>
      _setSyncDirectoryUseCase.execute(path, onProgress: onProgress);

  Future<AppThemeMode> getThemeMode() => _themeRepository.getThemeMode();

  Future<void> setThemeMode(AppThemeMode mode) =>
      _themeRepository.setThemeMode(mode);
}
