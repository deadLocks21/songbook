import 'package:songbook/core/domain/model/uuid_value.dart';

/// Où en est une source suivie, telle que le serveur la rapporte à chaque
/// synchro.
///
/// Sert à savoir, en une seule requête plutôt qu'une par source, si l'amont est
/// resté là où une copie l'a laissé — auquel cas la source *est* la base, et
/// un appareil qui n'a pas d'instantané peut le saisir au passage.
///
/// L'app ne s'en sert plus pour signaler un tirage en attente : ouvrir une
/// liste suivie va voir d'elle-même.
class UpstreamState {
  final UuidValue sourceListId;

  /// Version courante de la source, ou `null` si elle n'existe plus du tout.
  final int? version;

  /// La source a disparu. La copie, elle, reste : elle appartient à son
  /// propriétaire et perd seulement la possibilité de tirer.
  final bool deleted;

  const UpstreamState({
    required this.sourceListId,
    required this.version,
    required this.deleted,
  });
}
