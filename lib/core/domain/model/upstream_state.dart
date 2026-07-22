import 'package:songbook/core/domain/model/uuid_value.dart';

/// Où en est une source suivie, telle que le serveur la rapporte à chaque
/// synchro.
///
/// Évite un appel par source pour savoir s'il y a quelque chose à tirer : il
/// suffit de comparer [version] au `sourceVersion` de sa copie.
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

  /// Y a-t-il quelque chose à prendre pour une copie restée à [sourceVersion] ?
  bool hasNewsFor(int sourceVersion) =>
      !deleted && version != null && version! > sourceVersion;
}
