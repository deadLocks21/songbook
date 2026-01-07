import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/infrastructure/theme/shared_preferences.theme_repository.dart';

part 'theme.repository_provider.g.dart';

/// Provider pour l'implémentation du repository de thème
@riverpod
SharedPreferencesThemeRepository themeRepository(Ref ref) {
  return SharedPreferencesThemeRepository();
}
