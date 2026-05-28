import 'package:songbook/core/domain/services/settings.repository.dart';

/// Implémentation en mémoire du SettingsRepository.
/// Utilisé pour le web et les tests.
class InMemorySettingsRepository implements SettingsRepository {
  static const String defaultBackendUrl = 'https://songbook.dtfh.fr';

  String _backendUrl = defaultBackendUrl;
  List<String> _selectedRecueils = const [];

  @override
  Future<String> getBackendUrl() async => _backendUrl;

  @override
  Future<void> setBackendUrl(String url) async {
    _backendUrl = url;
  }

  @override
  Future<List<String>> getSelectedRecueils() async => _selectedRecueils;

  @override
  Future<void> setSelectedRecueils(List<String> codes) async {
    _selectedRecueils = List.unmodifiable(codes);
  }
}
