import 'package:shared_preferences/shared_preferences.dart';
import 'package:songbook/core/domain/services/settings.repository.dart';

/// Implémentation du repository de paramètres utilisant SharedPreferences
class SharedPreferencesSettingsRepository implements SettingsRepository {
  static const String _backendUrlKey = 'backend_url';

  /// URL par défaut du backend au premier démarrage
  static const String defaultBackendUrl = 'https://songbook.dtfh.fr/example';

  /// Instance de SharedPreferences - nullable pour gérer l'initialisation
  SharedPreferences? _preferences;

  /// S'assure que SharedPreferences est initialisé
  Future<void> _ensureInitialized() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  @override
  Future<String> getBackendUrl() async {
    await _ensureInitialized();
    return _preferences!.getString(_backendUrlKey) ?? defaultBackendUrl;
  }

  @override
  Future<void> setBackendUrl(String url) async {
    await _ensureInitialized();
    await _preferences!.setString(_backendUrlKey, url);
  }
}
