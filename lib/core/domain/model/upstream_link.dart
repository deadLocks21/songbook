import 'package:songbook/core/domain/model/uuid_value.dart';

/// Ce qu'une copie retient de la liste dont elle est issue.
///
/// [sourceVersion] est la version de la source **au dernier tirage**, pas celle
/// où elle en est maintenant. C'est le repère de la copie : la comparer à la
/// version courante de la source dit s'il y a quelque chose à tirer, et elle
/// n'avance qu'une fois les changements repris.
///
/// Le lien ne porte que dans un sens. Une copie est une liste à part entière :
/// son propriétaire l'édite librement, il peut la partager à son tour, et elle
/// survit à la suppression de la source. Rien ici ne peut remonter vers l'amont.
class UpstreamLink {
  final UuidValue sourceListId;
  final int sourceVersion;

  const UpstreamLink({required this.sourceListId, required this.sourceVersion});

  /// Le lien tel qu'il arrive du serveur : les deux champs, ou aucun parce que
  /// la liste est une originale.
  ///
  /// Un demi-lien est une réponse malformée, pas une liste sans amont : le
  /// laisser passer couperait silencieusement l'abonnement d'une copie.
  static UpstreamLink? fromNullable(String? sourceListId, int? sourceVersion) {
    if (sourceListId == null && sourceVersion == null) return null;

    if (sourceListId == null || sourceVersion == null) {
      throw ArgumentError(
        'Un lien amont exige « sourceListId » et « sourceVersion », ou aucun des deux.',
      );
    }

    return UpstreamLink(
      sourceListId: UuidValue.parse(sourceListId),
      sourceVersion: sourceVersion,
    );
  }

  UpstreamLink pulledAt(int sourceVersion) =>
      UpstreamLink(sourceListId: sourceListId, sourceVersion: sourceVersion);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpstreamLink &&
          runtimeType == other.runtimeType &&
          sourceListId == other.sourceListId &&
          sourceVersion == other.sourceVersion;

  @override
  int get hashCode => Object.hash(sourceListId, sourceVersion);
}
