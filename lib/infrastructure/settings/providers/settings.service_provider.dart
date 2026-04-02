import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/application/services/settings.service.dart';
import 'package:songbook/core/domain/model/theme_mode.dart';
import 'package:songbook/infrastructure/settings/providers/settings.repository_provider.dart';
import 'package:songbook/infrastructure/theme/providers/theme.repository_provider.dart';

part 'settings.service_provider.g.dart';

@riverpod
SettingsService settingsService(Ref ref) {
  final settingsRepository = ref.watch(settingsRepositoryProvider);
  final themeRepository = ref.watch(themeRepositoryProvider);
  return SettingsService(settingsRepository, themeRepository);
}

@riverpod
class BackendUrlNotifier extends _$BackendUrlNotifier {
  @override
  Future<String?> build() async {
    final service = ref.watch(settingsServiceProvider);
    try {
      return await service.getBackendUrl();
    } catch (e) {
      return null;
    }
  }

  Future<void> setBackendUrl(String url) async {
    final service = ref.watch(settingsServiceProvider);
    try {
      await service.setBackendUrl(url);
      state = AsyncData(url);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

@riverpod
class SyncDirectoryNotifier extends _$SyncDirectoryNotifier {
  @override
  Future<String?> build() async {
    final service = ref.watch(settingsServiceProvider);
    try {
      return await service.getSyncDirectory();
    } catch (e) {
      return null;
    }
  }

  Future<void> setSyncDirectory(String? path,
      {void Function(double)? onProgress}) async {
    final service = ref.watch(settingsServiceProvider);
    try {
      await service.setSyncDirectory(path, onProgress: onProgress);
      state = AsyncData(path);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  Future<AppThemeMode> build() async {
    final service = ref.watch(settingsServiceProvider);
    try {
      return await service.getThemeMode();
    } catch (e) {
      return AppThemeMode.system;
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    final service = ref.watch(settingsServiceProvider);
    try {
      await service.setThemeMode(mode);
      state = AsyncData(mode);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
