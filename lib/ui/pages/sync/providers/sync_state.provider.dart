import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/application/usecases/compute_sync_diff.usecase.dart';
import 'package:songbook/core/application/usecases/execute_sync.usecase.dart';
import 'package:songbook/core/domain/model/sync_diff.dart';
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

/// Notifier pour gérer l'état de synchronisation
class SyncStateNotifier extends Notifier<SyncState> {
  ComputeSyncDiffUseCase get _computeSyncDiffUseCase =>
      ref.watch(computeSyncDiffUseCaseProvider);
  Future<ExecuteSyncUseCase> get _executeSyncUseCase =>
      ref.watch(executeSyncUseCaseProvider.future);

  @override
  SyncState build() {
    return const SyncInitial();
  }

  /// Calcule le diff entre les données locales et distantes
  Future<void> computeDiff(String baseUrl) async {
    try {
      state = const SyncComputing();
      final diff = await _computeSyncDiffUseCase.execute(baseUrl);

      if (diff.isEmpty) {
        // Si aucun changement, on reste en état initial pour permettre le retour automatique
        state = const SyncInitial();
      } else {
        state = SyncDiffComputed(diff);
      }
    } catch (e) {
      state = SyncError(e.toString());
    }
  }

  /// Exécute la synchronisation avec le diff fourni
  Future<void> executeSync(SyncDiff diff) async {
    try {
      state = const SyncExecuting();
      final executeUseCase = await _executeSyncUseCase;
      await executeUseCase.execute(diff);
      state = const SyncSuccess();
    } catch (e) {
      state = SyncError(e.toString());
    }
  }

  /// Remet l'état à initial
  void reset() {
    state = const SyncInitial();
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
