import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/upstream_change.dart';
import 'package:songbook/core/domain/model/upstream_snapshot.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';

/// Ce que l'auteur a fait à sa liste depuis mon dernier tirage, et ce que ça
/// donne appliqué à ma copie.
///
/// Le diff qui a du sens est `base → source` : *ce que l'auteur a fait*. Le
/// comparer à `ma copie → source` confondrait « l'auteur a ajouté ce chant »
/// avec « je l'avais retiré » — la même différence, deux intentions opposées.
///
/// Les deux côtés sont rapprochés par `songId` et non par identifiant
/// d'entrée : ceux de ma copie ont été regénérés à la duplication. Quand un
/// même chant figure plusieurs fois dans une liste, l'appariement devient
/// ambigu ; on préfère alors ne rien dire de sa tonalité plutôt que de deviner.
class UpstreamDiff {
  final List<UpstreamChange> changes;

  /// Calculé sans base, en comparant ma copie à la source.
  ///
  /// Arrive sur un appareil qui a reçu la copie par synchro plutôt que par
  /// abonnement : l'instantané est local et ne transite pas par le serveur. Le
  /// résultat reste juste tant que je n'ai rien modifié ; sinon mes propres
  /// modifications se présentent comme des changements de l'auteur, et l'écran
  /// doit le dire au lieu de faire semblant.
  final bool isApproximate;

  const UpstreamDiff({required this.changes, required this.isApproximate});

  bool get isEmpty => changes.isEmpty;

  /// Les changements qui défont un travail que j'ai fait de mon côté.
  List<UpstreamChange> get conflicting =>
      changes.where((c) => c.undoesMyWork).toList();

  /// Compare [source] à ce que j'avais pris la dernière fois.
  ///
  /// [base] absent bascule en comparaison à deux voies (cf. [isApproximate]).
  factory UpstreamDiff.between({
    required UpstreamSnapshot? base,
    required SongList mine,
    required SongList source,
  }) {
    final baseEntries = base?.entries ?? mine.entries;
    final baseScheduledAt = base?.scheduledAt ?? mine.scheduledAt;

    final changes = <UpstreamChange>[
      ..._songChanges(baseEntries, mine, source),
      ..._transpositionChanges(baseEntries, mine, source),
      if (!_sameMoment(baseScheduledAt, source.scheduledAt))
        ScheduleChangedUpstream(source.scheduledAt),
      ...?_orderChange(baseEntries, mine, source),
    ];

    return UpstreamDiff(changes: changes, isApproximate: base == null);
  }

  /// Ma copie, une fois appliqués les changements retenus.
  ///
  /// Ce qui n'est pas dans [selected] est laissé de côté définitivement : la
  /// base avance quand même, donc un changement écarté ne revient pas au
  /// tirage suivant. Refuser, c'est décider.
  SongList applyTo(SongList mine, {required Set<String> selected}) {
    final kept = changes.where((c) => selected.contains(c.id)).toList();
    var entries = [...mine.entries];
    var scheduledAt = mine.scheduledAt;

    for (final change in kept) {
      switch (change) {
        case SongRemovedUpstream(:final songId):
          final index = entries.indexWhere((e) => e.songId == songId);
          if (index != -1) entries.removeAt(index);

        case SongAddedUpstream(:final songId, :final savedSemitones):
          entries.add(
            SongListEntry(
              id: UuidValue.generate(),
              songId: songId,
              position: entries.length,
              savedSemitones: savedSemitones,
            ),
          );

        case TranspositionChangedUpstream(:final songId, :final semitones):
          final index = entries.indexWhere((e) => e.songId == songId);
          if (index != -1) {
            entries[index] = SongListEntry(
              id: entries[index].id,
              songId: songId,
              position: entries[index].position,
              savedSemitones: semitones,
            );
          }

        case ScheduleChangedUpstream(scheduledAt: final value):
          scheduledAt = value;

        case OrderChangedUpstream(:final songIds):
          entries = _reorder(entries, songIds);
      }
    }

    return mine.copyWith(
      scheduledAt: scheduledAt,
      entries: _renumbered(entries),
    );
  }

  /// Ajouts et retraits, chacun tu quand il n'a rien à changer chez moi.
  static List<UpstreamChange> _songChanges(
    List<SongListEntry> base,
    SongList mine,
    SongList source,
  ) {
    final baseCounts = _countBySong(base);
    final sourceCounts = _countBySong(source.entries);
    final mineSongs = mine.entries.map((e) => e.songId).toSet();

    final changes = <UpstreamChange>[];

    for (final songId in sourceCounts.keys) {
      final added = sourceCounts[songId]! - (baseCounts[songId] ?? 0);
      // Ajouté en amont, mais je l'ai déjà : sans effet, inutile de le montrer.
      if (added > 0 && !mineSongs.contains(songId)) {
        changes.add(
          SongAddedUpstream(
            songId: songId,
            savedSemitones: source.entries
                .firstWhere((e) => e.songId == songId)
                .savedSemitones,
          ),
        );
      }
    }

    for (final songId in baseCounts.keys) {
      final removed = baseCounts[songId]! - (sourceCounts[songId] ?? 0);
      // Retiré en amont, mais je l'avais déjà retiré : sans effet non plus.
      if (removed > 0 && mineSongs.contains(songId)) {
        final mineEntry = mine.entries.firstWhere((e) => e.songId == songId);
        changes.add(
          SongRemovedUpstream(
            songId: songId,
            transposedByMe: mineEntry.savedSemitones != null,
          ),
        );
      }
    }

    return changes;
  }

  static List<UpstreamChange> _transpositionChanges(
    List<SongListEntry> base,
    SongList mine,
    SongList source,
  ) {
    final changes = <UpstreamChange>[];

    for (final songId in _singleOccurrenceSongs(base)) {
      if (!_occursOnce(source.entries, songId)) continue;
      if (!_occursOnce(mine.entries, songId)) continue;

      final was = base.firstWhere((e) => e.songId == songId).savedSemitones;
      final now = source.entries
          .firstWhere((e) => e.songId == songId)
          .savedSemitones;
      if (was == now) continue;

      final mineValue = mine.entries
          .firstWhere((e) => e.songId == songId)
          .savedSemitones;

      changes.add(
        TranspositionChangedUpstream(
          songId: songId,
          semitones: now,
          // J'avais dévié de la base : appliquer écrase mon propre choix.
          overridesMine: mineValue != was,
        ),
      );
    }

    return changes;
  }

  /// L'ordre relatif des chants communs, comparé de part et d'autre.
  ///
  /// Restreint aux chants présents des deux côtés : sans cela, le moindre ajout
  /// décalerait la séquence et se ferait passer pour un réordonnancement.
  static List<UpstreamChange>? _orderChange(
    List<SongListEntry> base,
    SongList mine,
    SongList source,
  ) {
    final sourceSongs = source.entries.map((e) => e.songId).toSet();
    final common = base
        .map((e) => e.songId)
        .where(sourceSongs.contains)
        .toSet();

    if (common.length < 2) return null;

    final baseOrder = _orderRestrictedTo(base, common);
    final sourceOrder = _orderRestrictedTo(source.entries, common);
    if (_sameSequence(baseOrder, sourceOrder)) return null;

    final mineCommon = mine.entries
        .map((e) => e.songId)
        .where(common.contains)
        .toSet();

    return [
      OrderChangedUpstream(
        songIds: source.entries.map((e) => e.songId).toList(),
        overridesMine: !_sameSequence(
          _orderRestrictedTo(mine.entries, mineCommon),
          _orderRestrictedTo(source.entries, mineCommon),
        ),
      ),
    ];
  }

  /// Range mes entrées selon [songIds], en gardant à la fin celles que la
  /// source ne connaît pas : ce sont mes ajouts, adopter son ordre ne veut pas
  /// dire les perdre.
  static List<SongListEntry> _reorder(
    List<SongListEntry> entries,
    List<UuidValue> songIds,
  ) {
    final remaining = [...entries];
    final ordered = <SongListEntry>[];

    for (final songId in songIds) {
      final index = remaining.indexWhere((e) => e.songId == songId);
      if (index != -1) ordered.add(remaining.removeAt(index));
    }

    return [...ordered, ...remaining];
  }

  static List<SongListEntry> _renumbered(List<SongListEntry> entries) {
    return [
      for (var i = 0; i < entries.length; i++)
        SongListEntry(
          id: entries[i].id,
          songId: entries[i].songId,
          position: i,
          savedSemitones: entries[i].savedSemitones,
        ),
    ];
  }

  static Map<UuidValue, int> _countBySong(List<SongListEntry> entries) {
    final counts = <UuidValue, int>{};
    for (final entry in entries) {
      counts[entry.songId] = (counts[entry.songId] ?? 0) + 1;
    }
    return counts;
  }

  static Iterable<UuidValue> _singleOccurrenceSongs(
    List<SongListEntry> entries,
  ) => _countBySong(
    entries,
  ).entries.where((e) => e.value == 1).map((e) => e.key);

  static bool _occursOnce(List<SongListEntry> entries, UuidValue songId) =>
      entries.where((e) => e.songId == songId).length == 1;

  static List<UuidValue> _orderRestrictedTo(
    List<SongListEntry> entries,
    Set<UuidValue> keep,
  ) => entries.map((e) => e.songId).where(keep.contains).toList();

  static bool _sameSequence(List<UuidValue> a, List<UuidValue> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// `scheduledAt` est une heure « au mur » : comparer les instants suffit,
  /// mais la comparaison doit ignorer les micro-différences de sérialisation.
  static bool _sameMoment(DateTime a, DateTime b) =>
      a.toUtc().difference(b.toUtc()).inSeconds == 0;
}
