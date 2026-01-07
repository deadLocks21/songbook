import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/application/usecases/get_backend_url.usecase.dart';
import 'package:songbook/core/application/usecases/set_backend_url.usecase.dart';
import 'package:songbook/infrastructure/settings/providers/settings.repository_provider.dart';

part 'settings.usecases_provider.g.dart';

/// Provider pour le usecase de récupération de l'URL du backend
@riverpod
GetBackendUrlUseCase getBackendUrlUseCase(Ref ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return GetBackendUrlUseCase(repository);
}

/// Provider pour le usecase de définition de l'URL du backend
@riverpod
SetBackendUrlUseCase setBackendUrlUseCase(Ref ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SetBackendUrlUseCase(repository);
}

/// Notifier pour gérer l'état de l'URL du backend avec la nouvelle API Riverpod
@riverpod
class BackendUrlNotifier extends _$BackendUrlNotifier {
  @override
  Future<String?> build() async {
    final getUseCase = ref.watch(getBackendUrlUseCaseProvider);
    try {
      return await getUseCase.execute();
    } catch (e) {
      // En cas d'erreur, retourner null
      return null;
    }
  }

  /// Définit la nouvelle URL du backend
  Future<void> setBackendUrl(String url) async {
    final setUseCase = ref.watch(setBackendUrlUseCaseProvider);
    try {
      await setUseCase.execute(url);
      state = AsyncData(url);
    } catch (e) {
      // En cas d'erreur, mettre à jour l'état avec l'erreur
      state = AsyncError(e, StackTrace.current);
    }
  }
}
