import 'package:songbook/core/domain/model/theme_mode.dart';
import 'package:songbook/core/domain/services/theme.repository.dart';

/// Implémentation en mémoire du ThemeRepository.
/// Utilisé pour le web et les tests.
class InMemoryThemeRepository implements ThemeRepository {
  AppThemeMode _themeMode = AppThemeMode.system;

  @override
  Future<AppThemeMode> getThemeMode() async => _themeMode;

  @override
  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
  }
}
