import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/core/application/services/song_list_pull.service.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list.service_provider.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list_pull.provider.dart';
import 'package:songbook/ui/pages/song_list_pull/pull_review.sheet.dart';

/// Réagit à ce qu'a donné la vérification de la source.
///
/// Volontairement séparé de l'appel réseau : l'écran qui l'a lancé doit pouvoir
/// se dévoiler **avant** que la feuille d'arbitrage ne s'ouvre, sinon celle-ci
/// se poserait par-dessus un chargement.
///
/// Ne parle que quand il y a quelque chose à dire. Personne n'a rien demandé —
/// c'est l'ouverture de la liste qui a déclenché la vérification — donc « déjà
/// à jour » n'a pas à s'afficher. L'échec, lui, est présenté par l'écran
/// lui-même, qui propose de continuer sur la copie locale.
Future<void> presentPullResult(
  BuildContext context,
  WidgetRef ref,
  SongListDto songList,
  PullResult result,
) async {
  switch (result) {
    case NothingToPull():
    case PullFailed():
      break;

    case PulledAutomatically(:final changeCount):
      // Annoncé, lui : le contenu vient de changer sous les yeux de
      // l'utilisateur, il doit savoir pourquoi.
      _notify(
        context,
        '$changeCount changement${changeCount > 1 ? 's' : ''} repris de la liste partagée.',
      );

    case UpstreamGone():
      // La source a disparu : on coupe le lien plutôt que de reproposer une
      // vérification impossible à chaque ouverture. La copie, elle, reste.
      await ref.read(songListPullProvider.notifier).unfollow(songList.id);
      if (!context.mounted) return;
      _notify(
        context,
        'La liste partagée n\'existe plus. Votre copie est conservée.',
      );

    case NeedsReview(:final preview):
      // Rien à annoncer ensuite : la feuille applique ce qui a été retenu, et
      // l'utilisateur vient précisément de trancher. Vaut aussi s'il referme
      // sans décider — le repère n'a pas bougé, la question se reposera.
      await showPullReview(context, preview);
  }

  if (context.mounted) ref.invalidate(songListsProvider);
}

void _notify(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(key: const Key('songListPullMessage'), content: Text(message)),
  );
}
