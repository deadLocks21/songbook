import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';

/// L'état de la source au moment du dernier tirage, conservé en local.
///
/// C'est la **base** du futur tirage assisté. Sans elle, « l'auteur a ajouté ce
/// chant » et « je l'avais retiré » se présentent exactement pareil : une
/// différence entre ma copie et la source. Le diff qui a du sens est
/// `base → source`, c'est-à-dire *ce que l'auteur a fait depuis la dernière
/// fois* — pas `ma copie → source`.
///
/// Les [entries] portent les identifiants **de la source**, pas ceux de ma
/// copie : ceux-ci sont regénérés à la duplication (un identifiant d'entrée est
/// unique côté serveur, il ne peut pas être réutilisé). Rapprocher les deux
/// côtés se fait donc par `songId`.
class UpstreamSnapshot {
  /// Ma copie, à laquelle cet instantané se rapporte.
  final UuidValue songListId;

  /// Version de la source que décrit cet instantané.
  final int sourceVersion;

  final String? title;
  final DateTime scheduledAt;
  final List<SongListEntry> entries;
  final DateTime capturedAt;

  const UpstreamSnapshot({
    required this.songListId,
    required this.sourceVersion,
    required this.title,
    required this.scheduledAt,
    required this.entries,
    required this.capturedAt,
  });

  /// [mine] est-elle encore exactement ce que j'avais pris ?
  ///
  /// Si oui, il n'y a rien à arbitrer et le tirage peut s'appliquer en
  /// silence : c'est le cas courant, et il doit rester invisible.
  ///
  /// La comparaison porte sur les chants, leur ordre et leur tonalité — pas sur
  /// les identifiants d'entrée, qui diffèrent des deux côtés par construction.
  bool describes(SongList mine) {
    if (scheduledAt.toUtc() != mine.scheduledAt.toUtc()) return false;
    if (entries.length != mine.entries.length) return false;

    for (var i = 0; i < entries.length; i++) {
      if (entries[i].songId != mine.entries[i].songId) return false;
      if (entries[i].savedSemitones != mine.entries[i].savedSemitones) {
        return false;
      }
    }

    return true;
  }

  /// L'instantané pris quand [source] vient d'être dupliquée en [songListId].
  factory UpstreamSnapshot.of(
    UuidValue songListId,
    SongList source, {
    DateTime? capturedAt,
  }) {
    final version = source.version;
    if (version == null) {
      throw ArgumentError(
        'Une source jamais poussée n\'a pas de version à retenir.',
      );
    }

    return UpstreamSnapshot(
      songListId: songListId,
      sourceVersion: version,
      title: source.title,
      scheduledAt: source.scheduledAt,
      entries: source.entries,
      capturedAt: capturedAt ?? DateTime.now(),
    );
  }
}
