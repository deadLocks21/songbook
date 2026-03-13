import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/domain/services/theme.repository.dart';
import 'package:songbook/infrastructure/theme/in_memory.theme_repository.dart';
import 'package:songbook/infrastructure/theme/shared_preferences.theme_repository.dart';

part 'theme.repository_provider.g.dart';

/// Provider pour l'implémentation du repository de thème.
/// Utilise InMemoryThemeRepository sur le web, SharedPreferencesThemeRepository sinon.
@riverpod
ThemeRepository themeRepository(Ref ref) {
  if (kIsWeb) {
    return InMemoryThemeRepository();
  }
  return SharedPreferencesThemeRepository();
}
