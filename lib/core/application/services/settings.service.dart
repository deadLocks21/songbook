import 'package:songbook/core/domain/model/display_resource_type.dart';
import 'package:songbook/core/domain/model/theme_mode.dart';
import 'package:songbook/core/domain/services/settings.repository.dart';
import 'package:songbook/core/domain/services/theme.repository.dart';

class SettingsService {
  final SettingsRepository _settingsRepository;
  final ThemeRepository _themeRepository;

  SettingsService(this._settingsRepository, this._themeRepository);

  Future<String> getBackendUrl() => _settingsRepository.getBackendUrl();

  Future<void> setBackendUrl(String url) =>
      _settingsRepository.setBackendUrl(url);

  Future<List<String>> getSelectedRecueils() =>
      _settingsRepository.getSelectedRecueils();

  Future<void> setSelectedRecueils(List<String> codes) =>
      _settingsRepository.setSelectedRecueils(codes);

  Future<AppThemeMode> getThemeMode() => _themeRepository.getThemeMode();

  Future<void> setThemeMode(AppThemeMode mode) =>
      _themeRepository.setThemeMode(mode);

  Future<List<DisplayResourceType>> getResourceDisplayOrder() =>
      _settingsRepository.getResourceDisplayOrder();

  Future<void> setResourceDisplayOrder(List<DisplayResourceType> order) =>
      _settingsRepository.setResourceDisplayOrder(order);
}
