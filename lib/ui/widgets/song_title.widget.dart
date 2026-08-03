import 'package:flutter/material.dart';

/// Le code puis le nom d'un chant, sur une ligne.
///
/// Le code garde sa place devant, mais en plus petit et en retrait : c'est un
/// repère pour trouver le chant, pas son nom. Aligné sur la même ligne de base
/// pour que les deux tailles ne donnent pas l'impression de flotter l'une par
/// rapport à l'autre.
///
/// Partagé par le sélecteur et le catalogue : c'est le même objet qu'on
/// présente, il doit se lire pareil des deux côtés.
class SongTitle extends StatelessWidget {
  final String code;
  final String name;

  /// Style du nom. Par défaut celui du contexte — le `ListTile` du sélecteur
  /// impose déjà le sien ; la carte du catalogue, elle, doit le dire.
  final TextStyle? nameStyle;

  const SongTitle({
    super.key,
    required this.code,
    required this.name,
    this.nameStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          code,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Text(
            name,
            style: nameStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
