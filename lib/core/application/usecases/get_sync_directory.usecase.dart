import 'package:songbook/core/domain/services/settings.repository.dart';

/// Cas d'usage pour récupérer le répertoire de synchronisation personnalisé
class GetSyncDirectoryUseCase {
  final SettingsRepository _settingsRepository;

  GetSyncDirectoryUseCase(this._settingsRepository);

  /// Retourne le répertoire personnalisé, ou null si l'emplacement par défaut est utilisé
  Future<String?> execute() async {
    return await _settingsRepository.getSyncDirectory();
  }
}
