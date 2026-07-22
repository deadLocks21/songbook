import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/application/services/share_link.parser.dart';
import 'package:songbook/core/application/services/song_list_sharing.service.dart';
import 'package:songbook/core/domain/services/deep_link.source.dart';
import 'package:songbook/infrastructure/deeplink/app_links.deep_link.source.dart';
import 'package:songbook/infrastructure/logger/providers/logger.service_provider.dart';
import 'package:songbook/infrastructure/settings/providers/settings.service_provider.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list_sharing.provider.dart';
import 'package:songbook/ui/pages/auth/providers/auth_state.provider.dart';

part 'share_link_handler.provider.g.dart';

@Riverpod(keepAlive: true)
DeepLinkSource deepLinkSource(Ref ref) {
  // Le web n'a pas de lien entrant à intercepter : la page *est* déjà ouverte.
  if (kIsWeb) return const NoDeepLinkSource();

  return AppLinksDeepLinkSource();
}

/// Ce que l'écran doit montrer après un lien reçu. `null` tant qu'il n'y a rien
/// à dire — l'état vit dans le temps, l'événement non.
sealed class ShareLinkEvent {
  const ShareLinkEvent();
}

/// Le lien a abouti : voici ce qu'il a produit.
class ShareLinkFollowed extends ShareLinkEvent {
  final FollowOutcome outcome;

  const ShareLinkFollowed(this.outcome);
}

/// Le lien vient d'une autre instance que celle configurée.
class ShareLinkFromElsewhere extends ShareLinkEvent {
  final String origin;

  const ShareLinkFromElsewhere(this.origin);
}

/// Le lien ne mène à rien, ou le serveur n'a pas répondu.
class ShareLinkFailed extends ShareLinkEvent {
  final bool rejected;

  const ShareLinkFailed({required this.rejected});
}

/// Reçoit les liens de partage et les fait aboutir.
///
/// Deux règles portent tout le reste :
///
/// - **Un lien reçu déconnecté n'est pas perdu.** Il est mis de côté, le flux
///   OTP se déroule, et l'abonnement reprend tout seul à l'arrivée. Sans cela,
///   le cas le plus courant — on clique un lien, l'app s'ouvre sur l'écran de
///   connexion — obligerait à retrouver le message et à recliquer.
/// - **Un lien d'une autre instance est refusé explicitement.** L'URL du
///   backend est saisie par l'utilisateur : un lien émis ailleurs pointe une
///   autre base de comptes, le jeton n'y voudra rien dire.
@Riverpod(keepAlive: true)
class ShareLinkHandler extends _$ShareLinkHandler {
  StreamSubscription<Uri>? _subscription;

  /// Le jeton reçu alors que personne n'était connecté, en attente du retour de
  /// l'authentification. En mémoire : le flux OTP ne relance pas le processus.
  String? _pendingToken;

  @override
  ShareLinkEvent? build() {
    ref.onDispose(() => _subscription?.cancel());

    // Reprend l'abonnement mis de côté dès que la session est ouverte.
    ref.listen(authNotifierProvider, (_, next) {
      if (next is AuthAuthenticated) unawaited(_drainPending());
    });

    unawaited(_start());

    return null;
  }

  /// Consomme l'événement affiché, pour qu'un rebuild ne le rejoue pas.
  void acknowledge() => state = null;

  Future<void> _start() async {
    final source = ref.read(deepLinkSourceProvider);

    _subscription ??= source.linkStream().listen(
      handle,
      onError: (Object e, StackTrace stack) => ref
          .read(loggerProvider)
          .warn('share_link.stream_failed', error: e, stack: stack),
    );

    final initial = await source.initialLink();
    if (initial != null) await handle(initial);
  }

  /// Traite une URL entrante. Exposé pour que le comportement se vérifie sans
  /// plugin natif.
  Future<void> handle(Uri uri) async {
    final logger = ref.read(loggerProvider);
    final backendUrl = await ref.read(backendUrlProvider.future);
    final target = ShareLinkParser.parse(uri, backendUrl: backendUrl);

    switch (target) {
      case ShareLinkIrrelevant():
        return;
      case ShareLinkForeignOrigin(:final origin):
        logger.info('share_link.foreign_origin');
        state = ShareLinkFromElsewhere(origin);
      case ShareLinkInvite(:final token):
        if (ref.read(authNotifierProvider) is! AuthAuthenticated) {
          // Mis de côté plutôt que perdu : l'utilisateur ne devrait pas avoir à
          // retourner chercher le message une fois connecté.
          logger.info('share_link.deferred_until_signed_in');
          _pendingToken = token;
          return;
        }
        await _follow(token);
    }
  }

  Future<void> _drainPending() async {
    final token = _pendingToken;
    if (token == null) return;

    _pendingToken = null;
    await _follow(token);
  }

  Future<void> _follow(String token) async {
    final result = await ref
        .read(songListSharingProvider.notifier)
        .follow(token: token);

    state = switch (result) {
      FollowSucceeded(:final outcome) => ShareLinkFollowed(outcome),
      FollowRejected() => const ShareLinkFailed(rejected: true),
      FollowFailed() => const ShareLinkFailed(rejected: false),
    };
  }
}
