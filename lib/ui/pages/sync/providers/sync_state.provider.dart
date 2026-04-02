import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/application/services/error_message.service.dart';
import 'package:songbook/core/application/services/sync.service.dart';
import 'package:songbook/core/domain/exceptions/password_required.exception.dart';
import 'package:songbook/core/domain/model/sync_diff.dart';
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
  final double progress;

  const SyncComputing({this.progress = 0.0});
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
  final double progress;

  const SyncExecuting({this.progress = 0.0});
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
  Future<SyncService> get _syncService =>
      ref.watch(syncServiceProvider.future);

  /// URL actuelle en cours de traitement (pour les retry après saisie du mot de passe)
  String? _currentUrl;

  @override
  SyncState build() {
    return const SyncInitial();
  }

  /// Calcule le diff entre les données locales et distantes
  Future<void> computeDiff(String baseUrl) async {
    try {
      state = const SyncComputing(progress: 0.0);
      _currentUrl = baseUrl;
      final syncService = await _syncService;
      final diff = await syncService.computeDiff(
        baseUrl,
        onProgress: (progress) => state = SyncComputing(progress: progress),
      );

      if (diff.isEmpty) {
        state = const SyncUpToDate();
      } else {
        state = SyncDiffComputed(diff);
      }
    } catch (e, stackTrace) {
      debugPrint('Error during sync: $e\n$stackTrace');

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
      state = const SyncExecuting(progress: 0.0);
      final syncService = await _syncService;
      await syncService.executeSync(
        diff,
        onProgress: (progress) => state = SyncExecuting(progress: progress),
      );

      ref.invalidate(songsProvider);

      state = const SyncSuccess();
    } catch (e, stackTrace) {
      debugPrint('Error during sync: $e\n$stackTrace');

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
      final syncService = await _syncService;
      await syncService.setPassword(password);

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

/// Provider pour le notifier de synchronisation
final syncStateNotifierProvider =
    NotifierProvider<SyncStateNotifier, SyncState>(() {
      return SyncStateNotifier();
    });

/// Provider pour l'état de synchronisation (pour un accès direct)
final syncStateProvider = Provider<SyncState>((ref) {
  return ref.watch(syncStateNotifierProvider);
});
