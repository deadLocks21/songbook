import 'package:songbook/core/domain/model/theme_mode.dart';
import 'package:songbook/core/domain/services/theme.repository.dart';

/// Cas d'usage pour récupérer le mode de thème actuel
class GetThemeModeUseCase {
  final ThemeRepository _themeRepository;

  GetThemeModeUseCase(this._themeRepository);

  /// Exécute le cas d'usage pour récupérer le mode de thème
  Future<AppThemeMode> execute() async {
    return await _themeRepository.getThemeMode();
  }
}
