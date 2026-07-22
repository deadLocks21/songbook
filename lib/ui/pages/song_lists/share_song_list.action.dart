import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list_sharing.provider.dart';
import 'package:songbook/ui/utils/date_format.dart';

/// Ouvre une liste au partage puis passe la main à la feuille système.
///
/// Partagé entre la vue d'ensemble et le détail : le message part avec le lien
/// **et** le code, et cette composition ne doit pas se mettre à diverger d'un
/// écran à l'autre — c'est ce que lit le destinataire.
///
/// Le lien est cliquable dans la plupart des messageries, mais pas toutes, et
/// quelqu'un qui ne peut pas cliquer doit pouvoir s'en sortir en tapant huit
/// caractères.
Future<void> shareSongList(
  BuildContext context,
  WidgetRef ref,
  SongListDto songList,
) async {
  final link = await ref
      .read(songListSharingProvider.notifier)
      .share(songList.id);

  if (!context.mounted) return;

  if (link == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        key: Key('songListShareFailed'),
        content: Text(
          'Partage impossible : le serveur n\'a pas répondu. Réessayez une fois connecté.',
        ),
      ),
    );
    return;
  }

  await SharePlus.instance.share(
    ShareParams(
      subject: 'Liste du ${formatDate(songList.scheduledAt)}',
      text:
          'Voici ma liste de chants du ${formatDate(songList.scheduledAt)} :\n'
          '${link.link}\n\n'
          'Ou dans l\'app, « Suivre une liste » avec le code ${link.code}.',
    ),
  );
}
