import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/domain/services/settings.repository.dart';
import 'package:songbook/infrastructure/settings/in_memory.settings_repository.dart';
import 'package:songbook/infrastructure/settings/shared_preferences.settings_repository.dart';

part 'settings.repository_provider.g.dart';

/// Provider pour l'implémentation du repository de paramètres.
/// Utilise InMemorySettingsRepository sur le web, SharedPreferencesSettingsRepository sinon.
@riverpod
SettingsRepository settingsRepository(Ref ref) {
  if (kIsWeb) {
    return InMemorySettingsRepository();
  }
  return SharedPreferencesSettingsRepository();
}
