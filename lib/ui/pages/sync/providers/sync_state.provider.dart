import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/application/services/error_message.service.dart';
import 'package:songbook/core/application/services/logger_application.service.dart';
import 'package:songbook/core/application/services/sync.service.dart';
import 'package:songbook/infrastructure/logger/providers/logger.service_provider.dart';
import 'package:songbook/infrastructure/song/providers/song.service_provider.dart';
import 'package:songbook/infrastructure/song/providers/sync.providers.dart';

/// État de la synchronisation de la liste des chants.
sealed class SyncState {
  const SyncState();
}

/// Synchronisation en cours.
class SyncInProgress extends SyncState {
  const SyncInProgress();
}

/// Synchronisation terminée avec succès.
class SyncSuccess extends SyncState {
  const SyncSuccess();
}

/// Échec de la synchronisation (réseau, serveur, …).
class SyncFailure extends SyncState {
  final String message;

  const SyncFailure(this.message);
}

/// Notifier pour gérer la synchronisation de la liste des chants.
class SyncStateNotifier extends Notifier<SyncState> {
  SyncService get _syncService => ref.read(syncServiceProvider);

  LoggerApplicationService get _logger => ref.read(loggerProvider);

  @override
  SyncState build() => const SyncInProgress();

  /// Synchronise la liste des chants depuis [baseUrl].
  Future<void> sync(String baseUrl) async {
    _logger.info('sync.started', attrs: {'url.host': _hostOf(baseUrl)});
    state = const SyncInProgress();
    try {
      await _syncService.syncSongList(baseUrl);
      ref.invalidate(songsProvider);
      _logger.info('sync.completed');
      state = const SyncSuccess();
    } catch (e, stackTrace) {
      if (ErrorMessageService.isUnauthorized(e)) {
        // 401 invalid_token : session expirée/révoquée. La ré-authentification
        // (retour à l'OTP) est déclenchée par l'intercepteur — on n'affiche pas
        // d'erreur réseau et on laisse la redirection se faire.
        _logger.info('sync.unauthorized');
        return;
      }
      _logger.error('sync.failed', error: e, stack: stackTrace);
      state = SyncFailure(ErrorMessageService.getNetworkErrorMessage(e));
    }
  }

  static String _hostOf(String url) => Uri.tryParse(url)?.host ?? url;
}

/// Provider pour le notifier de synchronisation.
final syncStateNotifierProvider =
    NotifierProvider<SyncStateNotifier, SyncState>(SyncStateNotifier.new);

/// Provider pour l'état de synchronisation (accès en lecture seule).
final syncStateProvider = Provider<SyncState>(
  (ref) => ref.watch(syncStateNotifierProvider),
);
