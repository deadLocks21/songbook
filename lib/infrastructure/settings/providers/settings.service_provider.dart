import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/application/services/settings.service.dart';
import 'package:songbook/core/domain/model/theme_mode.dart';
import 'package:songbook/infrastructure/logger/providers/logger.service_provider.dart';
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
    } catch (e, stack) {
      ref.read(loggerProvider).warn(
        'settings.backend_url.load_failed',
        error: e,
        stack: stack,
      );
      return null;
    }
  }

  Future<void> setBackendUrl(String url) async {
    final service = ref.watch(settingsServiceProvider);
    try {
      await service.setBackendUrl(url);
      state = AsyncData(url);
    } catch (e, stack) {
      ref.read(loggerProvider).error(
        'settings.backend_url.save_failed',
        error: e,
        stack: stack,
      );
      state = AsyncError(e, StackTrace.current);
    }
  }
}

/// Codes des recueils sélectionnés pour le cache local des partitions.
@riverpod
class SelectedRecueilsNotifier extends _$SelectedRecueilsNotifier {
  @override
  Future<List<String>> build() async {
    final service = ref.watch(settingsServiceProvider);
    try {
      return await service.getSelectedRecueils();
    } catch (e, stack) {
      ref.read(loggerProvider).warn(
        'settings.selected_recueils.load_failed',
        error: e,
        stack: stack,
      );
      return const [];
    }
  }

  /// Coche ou décoche un recueil, puis persiste la nouvelle sélection.
  Future<void> toggle(String code, {required bool selected}) async {
    final current = state.value ?? const <String>[];
    final next = selected
        ? (current.contains(code) ? current : [...current, code])
        : current.where((c) => c != code).toList();
    await _save(next);
  }

  Future<void> _save(List<String> codes) async {
    final service = ref.watch(settingsServiceProvider);
    try {
      await service.setSelectedRecueils(codes);
      state = AsyncData(codes);
    } catch (e, stack) {
      ref.read(loggerProvider).error(
        'settings.selected_recueils.save_failed',
        error: e,
        stack: stack,
      );
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
    } catch (e, stack) {
      ref.read(loggerProvider).warn(
        'settings.theme_mode.load_failed',
        error: e,
        stack: stack,
      );
      return AppThemeMode.system;
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    final service = ref.watch(settingsServiceProvider);
    try {
      await service.setThemeMode(mode);
      state = AsyncData(mode);
    } catch (e, stack) {
      ref.read(loggerProvider).error(
        'settings.theme_mode.save_failed',
        error: e,
        stack: stack,
      );
      state = AsyncError(e, StackTrace.current);
    }
  }
}
