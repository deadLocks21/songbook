import 'package:shared_preferences/shared_preferences.dart';
import 'package:songbook/core/domain/model/theme_mode.dart';
import 'package:songbook/core/domain/services/theme.repository.dart';

/// Implémentation du repository de thème utilisant SharedPreferences
class SharedPreferencesThemeRepository implements ThemeRepository {
  static const String _themeModeKey = 'app_theme_mode';

  /// Instance de SharedPreferences - nullable pour gérer l'initialisation
  SharedPreferences? _preferences;

  /// S'assure que SharedPreferences est initialisé
  Future<void> _ensureInitialized() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  @override
  Future<AppThemeMode> getThemeMode() async {
    await _ensureInitialized();

    final storedValue = _preferences!.getString(_themeModeKey);
    if (storedValue == null) {
      return AppThemeMode.system; // Valeur par défaut
    }

    try {
      return AppThemeMode.values.firstWhere(
        (mode) => mode.name == storedValue,
        orElse: () => AppThemeMode.system, // Fallback en cas d'erreur
      );
    } catch (e) {
      // En cas d'erreur de parsing, retourner la valeur par défaut
      return AppThemeMode.system;
    }
  }

  @override
  Future<void> setThemeMode(AppThemeMode mode) async {
    await _ensureInitialized();

    await _preferences!.setString(_themeModeKey, mode.name);
  }
}
