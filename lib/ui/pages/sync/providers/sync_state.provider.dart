import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/application/services/error_message.service.dart';
import 'package:songbook/core/application/usecases/compute_sync_diff.usecase.dart';
import 'package:songbook/core/application/usecases/execute_sync.usecase.dart';
import 'package:songbook/core/application/usecases/set_password.usecase.dart';
import 'package:songbook/core/domain/exceptions/password_required.exception.dart';
import 'package:songbook/core/domain/model/sync_diff.dart';
import 'package:songbook/infrastructure/settings/providers/settings.usecases_provider.dart';
import 'package:songbook/infrastructure/song/providers/song.service_provider.dart';
import 'package:songbook/infrastructure/song/providers/sync.providers.dart';

/// État de la synchronisation
sealed class SyncState {
  const SyncState();
}

/// État initial, aucun calcul en cours
class SyncInitial extends SyncState {
  const SyncInitial();
}

/// Calcul du diff en cours
class SyncComputing extends SyncState {
  const SyncComputing();
}

/// Aucune modification détectée, tout est à jour
class SyncUpToDate extends SyncState {
  const SyncUpToDate();
}

/// Diff calculé et prêt à afficher
class SyncDiffComputed extends SyncState {
  final SyncDiff diff;

  const SyncDiffComputed(this.diff);
}

/// Exécution de la synchronisation en cours
class SyncExecuting extends SyncState {
  const SyncExecuting();
}

/// Synchronisation terminée avec succès
class SyncSuccess extends SyncState {
  const SyncSuccess();
}

/// Erreur survenue pendant la synchronisation
class SyncError extends SyncState {
  final String message;

  const SyncError(this.message);
}

/// Mot de passe requis pour accéder à l'API
class SyncPasswordRequired extends SyncState {
  const SyncPasswordRequired();
}

/// Notifier pour gérer l'état de synchronisation
class SyncStateNotifier extends Notifier<SyncState> {
  ComputeSyncDiffUseCase get _computeSyncDiffUseCase =>
      ref.watch(computeSyncDiffUseCaseProvider);
  Future<ExecuteSyncUseCase> get _executeSyncUseCase =>
      ref.watch(executeSyncUseCaseProvider.future);
  SetPasswordUseCase get _setPasswordUseCase =>
      ref.watch(setPasswordUseCaseProvider);

  /// URL actuelle en cours de traitement (pour les retry après saisie du mot de passe)
  String? _currentUrl;

  @override
  SyncState build() {
    return const SyncInitial();
  }

  /// Calcule le diff entre les données locales et distantes
  Future<void> computeDiff(String baseUrl) async {
    try {
      state = const SyncComputing();
      _currentUrl = baseUrl; // Stocker l'URL pour les retry
      final diff = await _computeSyncDiffUseCase.execute(baseUrl);

      if (diff.isEmpty) {
        // Si aucun changement, on passe à l'état "à jour"
        state = const SyncUpToDate();
      } else {
        state = SyncDiffComputed(diff);
      }
    } catch (e, stackTrace) {
      debugPrint('Error during sync: $e\n$stackTrace');

      // Gestion spécifique de l'exception PasswordRequiredException
      // Elle peut être directement l'exception ou wrappée dans une DioException
      if (e is PasswordRequiredException) {
        state = const SyncPasswordRequired();
        return;
      }
      if (e is DioException && e.error is PasswordRequiredException) {
        state = const SyncPasswordRequired();
        return;
      }

      final userMessage = ErrorMessageService.getNetworkErrorMessage(e);
      state = SyncError(userMessage);
    }
  }

  /// Exécute la synchronisation avec le diff fourni
  Future<void> executeSync(SyncDiff diff) async {
    try {
      state = const SyncExecuting();
      final executeUseCase = await _executeSyncUseCase;
      await executeUseCase.execute(diff);

      // Invalider le cache des chants pour forcer le rechargement
      ref.invalidate(songsProvider);

      state = const SyncSuccess();
    } catch (e, stackTrace) {
      debugPrint('Error during sync: $e\n$stackTrace');

      // Gestion spécifique de l'exception PasswordRequiredException
      // Elle peut être directement l'exception ou wrappée dans une DioException
      if (e is PasswordRequiredException) {
        state = const SyncPasswordRequired();
        return;
      }
      if (e is DioException && e.error is PasswordRequiredException) {
        state = const SyncPasswordRequired();
        return;
      }

      final userMessage = ErrorMessageService.getNetworkErrorMessage(e);
      state = SyncError(userMessage);
    }
  }

  /// Soumet le mot de passe et réessaye la synchronisation
  Future<void> submitPassword(String password) async {
    if (_currentUrl == null) {
      state = const SyncError('URL non disponible. Veuillez réessayer.');
      return;
    }

    try {
      // Stocker le mot de passe
      await _setPasswordUseCase.execute(password);

      // Réessayer la synchronisation avec le mot de passe
      await computeDiff(_currentUrl!);
    } catch (e, stackTrace) {
      debugPrint('Error submitting password: $e\n$stackTrace');
      final userMessage = ErrorMessageService.getNetworkErrorMessage(e);
      state = SyncError(userMessage);
    }
  }

  /// Annule la saisie du mot de passe et retourne à l'état d'erreur
  void cancelPasswordInput() {
    state = const SyncError('Authentification annulée par l\'utilisateur.');
  }

  /// Remet l'état à initial
  void reset() {
    state = const SyncInitial();
    _currentUrl = null;
  }
}

/// Provider pour combiner les deux use cases (nécessaire car executeSyncUseCaseProvider est async)
final syncUseCasesProvider =
    FutureProvider<(ComputeSyncDiffUseCase, ExecuteSyncUseCase)>((ref) async {
      final computeSyncDiffUseCase = ref.watch(computeSyncDiffUseCaseProvider);
      final executeSyncUseCase = await ref.watch(
        executeSyncUseCaseProvider.future,
      );

      return (computeSyncDiffUseCase, executeSyncUseCase);
    });

/// Provider pour le notifier de synchronisation
final syncStateNotifierProvider =
    NotifierProvider<SyncStateNotifier, SyncState>(() {
      return SyncStateNotifier();
    });

/// Provider pour l'état de synchronisation (pour un accès direct)
final syncStateProvider = Provider<SyncState>((ref) {
  return ref.watch(syncStateNotifierProvider);
});
