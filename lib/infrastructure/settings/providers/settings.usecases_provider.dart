import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/application/usecases/get_backend_url.usecase.dart';
import 'package:songbook/core/application/usecases/get_password.usecase.dart';
import 'package:songbook/core/application/usecases/get_sync_directory.usecase.dart';
import 'package:songbook/core/application/usecases/set_backend_url.usecase.dart';
import 'package:songbook/core/application/usecases/set_password.usecase.dart';
import 'package:songbook/core/application/usecases/set_sync_directory.usecase.dart';
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

/// Provider pour le use case de récupération du mot de passe.
@riverpod
GetPasswordUseCase getPasswordUseCase(Ref ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return GetPasswordUseCase(repository);
}

/// Provider pour le use case de stockage du mot de passe.
@riverpod
SetPasswordUseCase setPasswordUseCase(Ref ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SetPasswordUseCase(repository);
}

/// Provider pour le use case de récupération du répertoire de synchronisation.
@riverpod
GetSyncDirectoryUseCase getSyncDirectoryUseCase(Ref ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return GetSyncDirectoryUseCase(repository);
}

/// Provider pour le use case de définition du répertoire de synchronisation.
@riverpod
SetSyncDirectoryUseCase setSyncDirectoryUseCase(Ref ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SetSyncDirectoryUseCase(repository);
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

/// Notifier pour gérer l'état du répertoire de synchronisation
@riverpod
class SyncDirectoryNotifier extends _$SyncDirectoryNotifier {
  @override
  Future<String?> build() async {
    final getUseCase = ref.watch(getSyncDirectoryUseCaseProvider);
    try {
      return await getUseCase.execute();
    } catch (e) {
      return null;
    }
  }

  /// Définit le nouveau répertoire de synchronisation.
  /// Passer null pour revenir à l'emplacement par défaut.
  Future<void> setSyncDirectory(String? path, {void Function(double)? onProgress}) async {
    final setUseCase = ref.watch(setSyncDirectoryUseCaseProvider);
    try {
      await setUseCase.execute(path, onProgress: onProgress);
      state = AsyncData(path);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}
