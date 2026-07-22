import 'package:songbook/core/domain/model/uuid_value.dart';

/// Une chose que l'auteur a faite à sa liste depuis mon dernier tirage.
///
/// Chaque changement porte un [id] stable : c'est lui que l'écran de revue
/// coche ou décoche, et qui dit ensuite quoi appliquer.
sealed class UpstreamChange {
  const UpstreamChange();

  String get id;

  /// Ce changement mérite-t-il d'être signalé plus fort que les autres ?
  ///
  /// Vrai quand il défait un travail que j'ai fait de mon côté. C'est le seul
  /// cas où appliquer machinalement fait perdre quelque chose.
  bool get undoesMyWork => false;
}

/// L'auteur a ajouté un chant que je n'ai pas.
class SongAddedUpstream extends UpstreamChange {
  final UuidValue songId;
  final int? savedSemitones;

  const SongAddedUpstream({required this.songId, this.savedSemitones});

  @override
  String get id => 'added:${songId.value}';
}

/// L'auteur a retiré un chant que j'ai encore.
class SongRemovedUpstream extends UpstreamChange {
  final UuidValue songId;

  /// J'ai transposé ce chant de mon côté. Le retirer jette ce réglage — c'est
  /// le cas que l'écran doit montrer autrement qu'un retrait ordinaire.
  final bool transposedByMe;

  const SongRemovedUpstream({
    required this.songId,
    required this.transposedByMe,
  });

  @override
  String get id => 'removed:${songId.value}';

  @override
  bool get undoesMyWork => transposedByMe;
}

/// L'auteur a changé la tonalité retenue pour un chant.
class TranspositionChangedUpstream extends UpstreamChange {
  final UuidValue songId;
  final int? semitones;

  /// J'avais choisi une autre tonalité. Appliquer écrase mon choix.
  final bool overridesMine;

  const TranspositionChangedUpstream({
    required this.songId,
    required this.semitones,
    required this.overridesMine,
  });

  @override
  String get id => 'transposed:${songId.value}';

  @override
  bool get undoesMyWork => overridesMine;
}

/// L'auteur a changé la date prévue.
class ScheduleChangedUpstream extends UpstreamChange {
  final DateTime scheduledAt;

  const ScheduleChangedUpstream(this.scheduledAt);

  @override
  String get id => 'schedule';
}

/// L'auteur a réordonné sa liste.
///
/// Traité comme **un seul** changement, pas comme N déplacements : c'est
/// beaucoup plus lisible, et surtout honnête sur ce que ça écrase quand j'ai
/// réordonné de mon côté — un ordre ne s'applique pas à moitié.
class OrderChangedUpstream extends UpstreamChange {
  /// L'ordre des chants côté source.
  final List<UuidValue> songIds;

  /// J'avais mon propre ordre. L'adopter défait mon rangement.
  final bool overridesMine;

  const OrderChangedUpstream({
    required this.songIds,
    required this.overridesMine,
  });

  @override
  String get id => 'order';

  @override
  bool get undoesMyWork => overridesMine;
}
