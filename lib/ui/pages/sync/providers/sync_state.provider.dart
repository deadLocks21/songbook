import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/application/services/error_message.service.dart';
import 'package:songbook/core/application/services/logger_application.service.dart';
import 'package:songbook/core/application/services/sync.service.dart';
import 'package:songbook/core/application/usecases/cache_recueil_partitions.usecase.dart';
import 'package:songbook/infrastructure/logger/providers/logger.service_provider.dart';
import 'package:songbook/infrastructure/settings/providers/settings.service_provider.dart';
import 'package:songbook/infrastructure/song/providers/song.service_provider.dart';
import 'package:songbook/infrastructure/song/providers/sync.providers.dart';

/// État de la synchronisation de la liste des chants.
sealed class SyncState {
  const SyncState();
}

/// Synchronisation de la liste des chants en cours.
class SyncInProgress extends SyncState {
  const SyncInProgress();
}

/// Téléchargement des partitions des recueils sélectionnés en cours.
///
/// [total] vaut 0 tant que le nombre de partitions à télécharger n'est pas
/// connu (juste avant le premier téléchargement).
class SyncCachingPartitions extends SyncState {
  final int done;
  final int total;

  const SyncCachingPartitions(this.done, this.total);
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
      final remoteSongs = await _syncService.syncSongList(baseUrl);
      ref.invalidate(songsProvider);

      // Cache des partitions des recueils sélectionnés (téléchargement
      // bloquant, avec progression). Best effort : un échec ici ne remet pas en
      // cause la synchronisation de la liste déjà aboutie.
      final selected = await ref.read(selectedRecueilsProvider.future);
      if (selected.isNotEmpty) {
        final cache = await ref.read(resourceCacheRepositoryProvider.future);
        state = const SyncCachingPartitions(0, 0);
        await CacheRecueilPartitionsUseCase(cache).execute(
          remoteSongs,
          selected.toSet(),
          onProgress: (done, total) {
            state = SyncCachingPartitions(done, total);
          },
        );
      }

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
