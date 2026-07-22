import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/application/services/error_message.service.dart';
import 'package:songbook/core/application/services/song_list_sharing.service.dart';
import 'package:songbook/core/domain/exceptions/song_list_sync.exception.dart';
import 'package:songbook/core/domain/model/share_link.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/infrastructure/logger/providers/logger.service_provider.dart';
import 'package:songbook/infrastructure/settings/providers/settings.service_provider.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list.repository_provider.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list.service_provider.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list_sync.provider.dart';

part 'song_list_sharing.provider.g.dart';

@riverpod
SongListSharingService songListSharingService(Ref ref) {
  return SongListSharingService(
    ref.watch(songListRepositoryProvider),
    ref.watch(remoteSongListRepositoryProvider),
  );
}

/// L'issue d'un abonnement telle que l'écran doit la traiter.
///
/// Trois cas distincts parce que l'utilisateur a trois choses différentes à
/// comprendre : c'est fait, le code ne vaut rien, ou le serveur est
/// injoignable. Les confondre donnerait « échec » là où il faut « ce code
/// n'existe pas ».
sealed class FollowResult {
  const FollowResult();
}

class FollowSucceeded extends FollowResult {
  final FollowOutcome outcome;

  const FollowSucceeded(this.outcome);
}

/// Le lien ou le code ne mène à rien : jamais émis, mal recopié, ou pointant
/// une liste supprimée depuis.
class FollowRejected extends FollowResult {
  const FollowRejected();
}

/// L'échange n'a pas pu avoir lieu : réseau, serveur, session expirée.
class FollowFailed extends FollowResult {
  const FollowFailed();
}

/// Pilote le partage et l'abonnement depuis l'UI : résout l'URL du backend,
/// appelle le serveur, et rafraîchit les listes.
///
/// L'état est `true` pendant un appel réseau, pour que l'écran puisse
/// désactiver son bouton.
///
/// `keepAlive` pour la même raison que la synchro : une duplication déclenchée
/// depuis une boîte de dialogue doit survivre à sa fermeture.
@Riverpod(keepAlive: true)
class SongListSharingNotifier extends _$SongListSharingNotifier {
  @override
  bool build() => false;

  /// Ouvre une liste aux abonnements et rend de quoi la transmettre.
  ///
  /// Pousse d'abord : une liste créée hors ligne n'existe pas encore côté
  /// serveur, et il n'y aurait rien à partager. Un push qui échoue n'arrête
  /// pas — le serveur connaît peut-être déjà la liste.
  ///
  /// Retourne `null` si le partage n'a pas abouti.
  Future<ShareLink?> share(String listId) async {
    final logger = ref.read(loggerProvider);
    state = true;
    try {
      await ref.read(songListSyncProvider.notifier).push();

      final baseUrl = await ref.read(backendUrlProvider.future) ?? '';
      return await ref
          .read(songListSharingServiceProvider)
          .share(baseUrl, UuidValue.parse(listId));
    } catch (e, stack) {
      if (ErrorMessageService.isUnauthorized(e)) {
        logger.info('song_list.share.unauthorized');
        return null;
      }
      logger.warn('song_list.share.failed', error: e, stack: stack);
      return null;
    } finally {
      state = false;
    }
  }

  /// Échange un lien ou un code contre une copie locale de la liste.
  Future<FollowResult> follow({String? token, String? code}) async {
    final logger = ref.read(loggerProvider);
    state = true;
    try {
      final baseUrl = await ref.read(backendUrlProvider.future) ?? '';
      final outcome = await ref
          .read(songListSharingServiceProvider)
          .follow(baseUrl, token: token, code: code);

      ref.invalidate(songListsProvider);

      // La copie n'existe pour l'instant que sur cet appareil : on la pousse
      // sans attendre, pour qu'elle rejoigne les autres appareils et que la
      // recopier ailleurs ne crée pas un doublon.
      if (outcome.status == FollowStatus.copied) {
        await ref.read(songListSyncProvider.notifier).push();
      }

      return FollowSucceeded(outcome);
    } on ShareLinkNotFoundException {
      logger.info('song_list.follow.rejected');
      return const FollowRejected();
    } catch (e, stack) {
      if (ErrorMessageService.isUnauthorized(e)) {
        logger.info('song_list.follow.unauthorized');
        return const FollowFailed();
      }
      logger.warn('song_list.follow.failed', error: e, stack: stack);
      return const FollowFailed();
    } finally {
      state = false;
    }
  }
}
