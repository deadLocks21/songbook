import 'package:songbook/core/domain/model/display_resource_type.dart';
import 'package:songbook/core/domain/services/settings.repository.dart';

/// Implémentation en mémoire du SettingsRepository.
/// Utilisé pour le web et les tests.
class InMemorySettingsRepository implements SettingsRepository {
  /// Vide par défaut : aucune URL configurée → mode démo in-memory
  /// (cf. `inMemoryModeProvider`).
  static const String defaultBackendUrl = '';

  String _backendUrl = defaultBackendUrl;
  List<String> _selectedRecueils = const [];
  List<DisplayResourceType> _resourceDisplayOrder = const [
    DisplayResourceType.partition,
    DisplayResourceType.chordPro,
  ];

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

  @override
  Future<List<DisplayResourceType>> getResourceDisplayOrder() async =>
      _resourceDisplayOrder;

  @override
  Future<void> setResourceDisplayOrder(List<DisplayResourceType> order) async {
    _resourceDisplayOrder = List.unmodifiable(order);
  }
}
