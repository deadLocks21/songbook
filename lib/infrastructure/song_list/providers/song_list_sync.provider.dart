import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/application/services/error_message.service.dart';
import 'package:songbook/core/application/services/song_list_sync.service.dart';
import 'package:songbook/core/domain/services/remote_song_list.repository.dart';
import 'package:songbook/infrastructure/logger/providers/logger.service_provider.dart';
import 'package:songbook/infrastructure/settings/providers/in_memory_mode.provider.dart';
import 'package:songbook/infrastructure/settings/providers/settings.service_provider.dart';
import 'package:songbook/infrastructure/song/providers/sync.providers.dart';
import 'package:songbook/infrastructure/song_list/dio.remote_song_list.repository.dart';
import 'package:songbook/infrastructure/song_list/in_memory.remote_song_list.repository.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list.repository_provider.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list.service_provider.dart';
import 'package:songbook/infrastructure/song_list/providers/upstream_states.provider.dart';

part 'song_list_sync.provider.g.dart';

/// Provider pour le repository distant des listes de chants.
/// En mémoire en mode démo (web, aucune URL, ou URL « memory »), appels Dio
/// sinon — cf. [inMemoryModeProvider].
///
/// Comme le repository local en mémoire, la version démo garde son état en
/// instance : on épingle le provider pour ne pas le perdre à l'auto-dispose,
/// sinon chaque synchro repartirait d'un serveur vide et effacerait tout.
@riverpod
RemoteSongListRepository remoteSongListRepository(Ref ref) {
  if (ref.watch(inMemoryModeProvider)) {
    ref.keepAlive();
    return InMemoryRemoteSongListRepository();
  }
  return DioRemoteSongListRepository(ref.watch(dioProvider));
}

/// Provider pour le service de synchronisation des listes de chants.
@riverpod
SongListSyncService songListSyncService(Ref ref) {
  // Le notifier est résolu **maintenant**, et c'est sa méthode qu'on passe au
  // service — pas une fermeture qui capturerait `ref`.
  //
  // Ce provider est auto-dispose et l'appelant ne fait que le lire : il est
  // donc jeté aussitôt, pendant que la synchro qu'il vient de démarrer continue
  // sur le réseau. Une fermeture sur `ref` explosait au retour, quand elle
  // voulait rapporter l'état amont. `upstreamStatesProvider` est `keepAlive`,
  // son instance survit sans risque à la disparition de ce provider-ci.
  final upstreamStates = ref.watch(upstreamStatesProvider.notifier);

  return SongListSyncService(
    ref.watch(songListRepositoryProvider),
    ref.watch(remoteSongListRepositoryProvider),
    // Seule occasion de savoir où en sont les sources suivies : c'est le pull
    // qui les rapporte, et l'UI en a besoin pour signaler un tirage disponible.
    onUpstreamStates: upstreamStates.record,
  );
}

/// Pilote la synchronisation des listes depuis l'UI : résout l'URL du backend,
/// lance la synchro et rafraîchit les écrans concernés.
///
/// L'état est `true` pendant une synchro en cours.
///
/// Aucune méthode ne propage d'exception : les listes vivent d'abord en local,
/// et un serveur injoignable ne doit ni faire échouer un enregistrement ni
/// interrompre le démarrage. Ce qui n'a pas pu être poussé reste marqué comme
/// tel et repartira à la synchro suivante.
///
/// Volontairement `keepAlive` : un push déclenché par un enregistrement survit
/// à la fermeture de l'écran qui l'a lancé. Sous auto-dispose, quitter la page
/// d'édition juste après avoir sauvegardé pourrait interrompre l'envoi.
@Riverpod(keepAlive: true)
class SongListSyncNotifier extends _$SongListSyncNotifier {
  @override
  bool build() => false;

  /// Synchro complète : pousse les modifications locales, puis récupère l'état
  /// du serveur. Retourne `false` si la synchro n'a pas abouti.
  Future<bool> sync() => _run(
    (service, baseUrl) => service.sync(baseUrl),
    operation: 'song_list.sync',
  );

  /// Envoi seul, après un enregistrement ou une suppression : inutile de tirer
  /// le serveur alors qu'on vient d'écrire en local.
  Future<bool> push() => _run(
    (service, baseUrl) => service.push(baseUrl),
    operation: 'song_list.push',
  );

  Future<bool> _run(
    Future<void> Function(SongListSyncService service, String baseUrl) action, {
    required String operation,
  }) async {
    final logger = ref.read(loggerProvider);
    state = true;
    try {
      final baseUrl = await ref.read(backendUrlProvider.future) ?? '';
      await action(ref.read(songListSyncServiceProvider), baseUrl);
      ref.invalidate(songListsProvider);
      return true;
    } catch (e, stack) {
      if (ErrorMessageService.isUnauthorized(e)) {
        // 401 invalid_token : l'intercepteur Dio a déjà purgé la session et
        // déclenché le retour à l'écran OTP. Rien à signaler de plus ici.
        logger.info('$operation.unauthorized');
        return false;
      }
      logger.warn('$operation.failed', error: e, stack: stack);
      return false;
    } finally {
      state = false;
    }
  }
}
