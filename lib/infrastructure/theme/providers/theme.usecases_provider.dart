import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/application/usecases/get_theme_mode.usecase.dart';
import 'package:songbook/core/application/usecases/set_theme_mode.usecase.dart';
import 'package:songbook/core/domain/model/theme_mode.dart';
import 'package:songbook/infrastructure/theme/providers/theme.repository_provider.dart';

part 'theme.usecases_provider.g.dart';

/// Provider pour le usecase de récupération du thème
@riverpod
GetThemeModeUseCase getThemeModeUseCase(Ref ref) {
  final repository = ref.watch(themeRepositoryProvider);
  return GetThemeModeUseCase(repository);
}

/// Provider pour le usecase de définition du thème
@riverpod
SetThemeModeUseCase setThemeModeUseCase(Ref ref) {
  final repository = ref.watch(themeRepositoryProvider);
  return SetThemeModeUseCase(repository);
}

/// Notifier pour gérer l'état du thème avec la nouvelle API Riverpod
@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  Future<AppThemeMode> build() async {
    final getUseCase = ref.watch(getThemeModeUseCaseProvider);
    try {
      return await getUseCase.execute();
    } catch (e) {
      // En cas d'erreur, retourner la valeur par défaut
      return AppThemeMode.system;
    }
  }

  /// Définit le nouveau mode de thème
  Future<void> setThemeMode(AppThemeMode mode) async {
    final setUseCase = ref.watch(setThemeModeUseCaseProvider);
    try {
      await setUseCase.execute(mode);
      state = AsyncData(mode);
    } catch (e) {
      // En cas d'erreur, mettre à jour l'état avec l'erreur
      state = AsyncError(e, StackTrace.current);
    }
  }
}
