import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/infrastructure/settings/shared_preferences.settings_repository.dart';

part 'settings.repository_provider.g.dart';

/// Provider pour l'implémentation du repository de paramètres
@riverpod
SharedPreferencesSettingsRepository settingsRepository(Ref ref) {
  return SharedPreferencesSettingsRepository();
}
