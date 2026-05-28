import 'package:shared_preferences/shared_preferences.dart';
import 'package:songbook/core/domain/services/settings.repository.dart';

/// Implémentation du repository de paramètres utilisant SharedPreferences
class SharedPreferencesSettingsRepository implements SettingsRepository {
  /// Clé SharedPreferences sous laquelle l'URL du backend est stockée.
  /// Publique pour que la migration de démarrage puisse la cibler.
  static const String backendUrlKey = 'backend_url';

  /// URL par défaut du backend au premier démarrage (domaine uniquement,
  /// les chemins d'API sont ajoutés dans le code via BackendEndpoints).
  static const String defaultBackendUrl = 'https://songbook.dtfh.fr';

  /// Clé SharedPreferences sous laquelle les codes des recueils sélectionnés
  /// (cache local des partitions) sont stockés.
  static const String selectedRecueilsKey = 'selected_recueils';

  /// Instance de SharedPreferences - nullable pour gérer l'initialisation
  SharedPreferences? _preferences;

  /// S'assure que SharedPreferences est initialisé
  Future<void> _ensureInitialized() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  @override
  Future<String> getBackendUrl() async {
    await _ensureInitialized();
    return _preferences!.getString(backendUrlKey) ?? defaultBackendUrl;
  }

  @override
  Future<void> setBackendUrl(String url) async {
    await _ensureInitialized();
    await _preferences!.setString(backendUrlKey, url);
  }

  @override
  Future<List<String>> getSelectedRecueils() async {
    await _ensureInitialized();
    return _preferences!.getStringList(selectedRecueilsKey) ?? const [];
  }

  @override
  Future<void> setSelectedRecueils(List<String> codes) async {
    await _ensureInitialized();
    await _preferences!.setStringList(selectedRecueilsKey, codes);
  }
}
