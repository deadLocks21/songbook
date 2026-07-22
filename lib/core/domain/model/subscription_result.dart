import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';

/// Ce que répond le serveur quand on échange un lien ou un code.
///
/// Deux situations ne sont **pas des erreurs** et demandent seulement de ne pas
/// dupliquer : un lien revenu à son auteur, et un lien déjà utilisé ici. Les
/// traiter comme des échecs afficherait un message d'erreur là où il suffit
/// d'ouvrir la liste que l'utilisateur a déjà.
class SubscriptionResult {
  /// La liste source, complète, prête à être dupliquée.
  final SongList source;

  /// L'appelant est l'auteur de cette liste : rien à suivre, rien à copier.
  final bool alreadyOwner;

  /// L'appelant a déjà une copie de cette source.
  final UuidValue? existingCopyId;

  const SubscriptionResult({
    required this.source,
    required this.alreadyOwner,
    required this.existingCopyId,
  });

  /// Faut-il fabriquer une copie, ou juste ouvrir une liste déjà présente ?
  bool get needsCopy => !alreadyOwner && existingCopyId == null;

  /// La liste à ouvrir quand il n'y a rien à copier.
  UuidValue? get listToOpen => alreadyOwner ? source.id : existingCopyId;
}
