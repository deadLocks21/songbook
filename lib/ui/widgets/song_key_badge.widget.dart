import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/ui/pages/chord_pro_viewer/key_label.dart';
import 'package:songbook/ui/pages/chord_pro_viewer/providers/song_original_key.provider.dart';

/// Petit chip affichant la tonalité d'un chant (tonalité d'origine transposée
/// de [savedSemitones]). Résout la tonalité d'origine à la demande via
/// [songOriginalKeyProvider] ; n'affiche rien tant qu'elle est inconnue ou si
/// le fichier ne déclare pas de tonalité exploitable.
///
/// Le chip est mis en avant (couleur primaire) quand une transposition est
/// enregistrée pour cette liste, et discret quand il montre la tonalité
/// d'origine du chant.
class SongKeyBadge extends ConsumerWidget {
  final String songId;
  final String chordProUrl;
  final int? savedSemitones;

  const SongKeyBadge({
    super.key,
    required this.songId,
    required this.chordProUrl,
    this.savedSemitones,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final originalKey = ref
        .watch(songOriginalKeyProvider(songId, chordProUrl))
        .value;
    final label = transposedKeyLabel(originalKey, savedSemitones ?? 0);
    if (label == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final isCustom = (savedSemitones ?? 0) != 0;
    final background = isCustom
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final foreground = isCustom
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;

    return Container(
      key: const Key('songKeyBadge'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
