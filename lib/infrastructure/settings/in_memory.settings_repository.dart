import 'package:songbook/core/domain/services/settings.repository.dart';

/// Implémentation en mémoire du SettingsRepository.
/// Utilisé pour le web et les tests.
class InMemorySettingsRepository implements SettingsRepository {
  static const String defaultBackendUrl =
      'https://songbook.dtfh.fr/api/songs/examples';

  String _backendUrl = defaultBackendUrl;
  String? _password;

  @override
  Future<String> getBackendUrl() async => _backendUrl;

  @override
  Future<void> setBackendUrl(String url) async {
    _backendUrl = url;
  }

  @override
  Future<String?> getPassword() async => _password;

  @override
  Future<void> setPassword(String password) async {
    _password = password;
  }

  @override
  Future<void> clearPassword() async {
    _password = null;
  }
}
