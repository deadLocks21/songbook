import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/core/application/services/song_list_pull.service.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list.service_provider.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list_pull.provider.dart';
import 'package:songbook/ui/pages/song_list_pull/pull_review.sheet.dart';

/// Va voir où en est la source, et présente ce qu'elle a changé.
///
/// Déclenché à l'ouverture d'une liste suivie, jamais sur demande explicite :
/// l'utilisateur n'a rien réclamé, donc **on ne parle que quand il y a quelque
/// chose à dire**. « Déjà à jour » ou « serveur injoignable » à chaque
/// ouverture seraient du bruit — et dans le second cas, la liste s'affiche de
/// toute façon, hors ligne, comme n'importe quelle autre.
Future<void> pullSongList(
  BuildContext context,
  WidgetRef ref,
  SongListDto songList,
) async {
  final result = await ref
      .read(songListPullProvider.notifier)
      .pull(songList.id);

  if (!context.mounted) return;

  switch (result) {
    // Rien à reprendre, ou serveur muet : silence dans les deux cas.
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
      // La source a disparu : on coupe le lien plutôt que de reproposer un
      // tirage impossible à chaque ouverture. La copie, elle, reste.
      await ref.read(songListPullProvider.notifier).unfollow(songList.id);
      if (!context.mounted) return;
      _notify(
        context,
        'La liste partagée n\'existe plus. Votre copie est conservée.',
      );

    case NeedsReview(:final preview):
      final decision = await showPullReview(context, preview);
      if (!context.mounted) return;
      // `null` = refermée sans trancher. Rien n'a été appliqué, le repère n'a
      // pas bougé, la question se reposera : il n'y a rien à annoncer.
      if (decision != null) _notify(context, 'Liste mise à jour.');
  }

  if (context.mounted) ref.invalidate(songListsProvider);
}

void _notify(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(key: const Key('songListPullMessage'), content: Text(message)),
  );
}
