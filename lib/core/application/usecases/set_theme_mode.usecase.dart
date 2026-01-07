import 'package:songbook/core/domain/model/theme_mode.dart';
import 'package:songbook/core/domain/services/theme.repository.dart';

/// Cas d'usage pour définir le mode de thème
class SetThemeModeUseCase {
  final ThemeRepository _themeRepository;

  SetThemeModeUseCase(this._themeRepository);

  /// Exécute le cas d'usage pour définir le mode de thème
  Future<void> execute(AppThemeMode mode) async {
    await _themeRepository.setThemeMode(mode);
  }
}
