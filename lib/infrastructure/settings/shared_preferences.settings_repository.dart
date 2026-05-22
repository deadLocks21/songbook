import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:songbook/core/domain/services/settings.repository.dart';

/// Implémentation du repository de paramètres utilisant SharedPreferences
class SharedPreferencesSettingsRepository implements SettingsRepository {
  static const String _backendUrlKey = 'backend_url';
  static const String _syncDirectoryKey = 'sync_directory';

  /// URL par défaut du backend au premier démarrage
  static const String defaultBackendUrl =
      'https://songbook.dtfh.fr/api/songs/examples';

  /// Instance de SharedPreferences - nullable pour gérer l'initialisation
  SharedPreferences? _preferences;

  /// Instance de FlutterSecureStorage pour le stockage sécurisé du mot de passe
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    mOptions: MacOsOptions(
      accessibility: KeychainAccessibility.first_unlock,
      synchronizable: false,
    ),
  );

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

  @override
  Future<String?> getPassword() async {
    return await _secureStorage.read(key: 'api_password');
  }

  @override
  Future<void> setPassword(String password) async {
    await _secureStorage.write(key: 'api_password', value: password);
  }

  @override
  Future<void> clearPassword() async {
    await _secureStorage.delete(key: 'api_password');
  }

  @override
  Future<String?> getSyncDirectory() async {
    await _ensureInitialized();
    return _preferences!.getString(_syncDirectoryKey);
  }

  @override
  Future<void> setSyncDirectory(String? path) async {
    await _ensureInitialized();
    if (path == null) {
      await _preferences!.remove(_syncDirectoryKey);
    } else {
      await _preferences!.setString(_syncDirectoryKey, path);
    }
  }
}
