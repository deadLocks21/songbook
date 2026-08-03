import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/upstream_change.dart';
import 'package:songbook/core/domain/model/upstream_link.dart';
import 'package:songbook/core/domain/model/upstream_diff.dart';
import 'package:songbook/core/domain/model/upstream_snapshot.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';

/// Le calcul du tirage.
///
/// Tout repose sur un point : le diff se fait `base → source`, jamais
/// `ma copie → source`. Les deux confondraient « l'auteur a ajouté ce chant »
/// et « je l'avais retiré » — la même différence, deux intentions opposées.
///
/// Les identifiants d'entrée diffèrent volontairement entre la source et ma
/// copie : ils sont regénérés à la duplication, et l'appariement se fait par
/// chant. Les fabriques ci-dessous respectent cette réalité.
void main() {
  group('UpstreamDiff — ce que l\'auteur a fait', () {
    test('signale un chant ajouté en amont', () {
      final diff = UpstreamDiff.between(
        base: snapshot([alpha, beta]),
        mine: copy([alpha, beta]),
        source: source([alpha, beta, gamma]),
      );

      expect(diff.changes, hasLength(1));
      expect(diff.changes.single, isA<SongAddedUpstream>());
      expect((diff.changes.single as SongAddedUpstream).songId, gamma.id);
    });

    test('tait un ajout dont je dispose déjà', () {
      // Sans effet chez moi : l'afficher demanderait un arbitrage sur rien.
      final diff = UpstreamDiff.between(
        base: snapshot([alpha]),
        mine: copy([alpha, gamma]),
        source: source([alpha, gamma]),
      );

      expect(diff.changes, isEmpty);
    });

    test('signale un chant retiré en amont', () {
      final diff = UpstreamDiff.between(
        base: snapshot([alpha, beta]),
        mine: copy([alpha, beta]),
        source: source([alpha]),
      );

      expect(diff.changes.single, isA<SongRemovedUpstream>());
      expect(diff.changes.single.undoesMyWork, isFalse);
    });

    test('tait un retrait que j\'avais déjà fait', () {
      final diff = UpstreamDiff.between(
        base: snapshot([alpha, beta]),
        mine: copy([alpha]),
        source: source([alpha]),
      );

      expect(diff.changes, isEmpty);
    });

    test('signale plus fort le retrait d\'un chant que j\'ai transposé', () {
      // Le seul cas où appliquer machinalement fait perdre du travail.
      final diff = UpstreamDiff.between(
        base: snapshot([alpha, beta]),
        mine: copy([alpha, beta.transposed(3)]),
        source: source([alpha]),
      );

      final removed = diff.changes.whereType<SongRemovedUpstream>().single;
      expect(removed.transposedByMe, isTrue);
      expect(removed.undoesMyWork, isTrue);
      expect(diff.conflicting, hasLength(1));
    });

    test('signale une tonalité changée en amont', () {
      final diff = UpstreamDiff.between(
        base: snapshot([alpha, beta]),
        mine: copy([alpha, beta]),
        source: source([alpha, beta.transposed(2)]),
      );

      final change = diff.changes
          .whereType<TranspositionChangedUpstream>()
          .single;
      expect(change.semitones, 2);
      expect(change.overridesMine, isFalse);
    });

    test('avertit quand la tonalité amont écrase la mienne', () {
      final diff = UpstreamDiff.between(
        base: snapshot([alpha, beta]),
        mine: copy([alpha, beta.transposed(-1)]),
        source: source([alpha, beta.transposed(2)]),
      );

      final change = diff.changes
          .whereType<TranspositionChangedUpstream>()
          .single;
      expect(change.overridesMine, isTrue);
      expect(change.undoesMyWork, isTrue);
    });

    test('signale un réordonnancement comme un seul changement', () {
      // Pas N déplacements : un ordre ne s'applique pas à moitié, et le
      // présenter par morceaux serait illisible.
      final diff = UpstreamDiff.between(
        base: snapshot([alpha, beta, gamma]),
        mine: copy([alpha, beta, gamma]),
        source: source([gamma, alpha, beta]),
      );

      expect(diff.changes.whereType<OrderChangedUpstream>(), hasLength(1));
    });

    test('ne prend pas un simple ajout pour un réordonnancement', () {
      // Régression : comparer les séquences brutes ferait passer tout ajout en
      // tête pour un rangement complet.
      final diff = UpstreamDiff.between(
        base: snapshot([alpha, beta]),
        mine: copy([alpha, beta]),
        source: source([gamma, alpha, beta]),
      );

      expect(diff.changes.whereType<OrderChangedUpstream>(), isEmpty);
      expect(diff.changes.whereType<SongAddedUpstream>(), hasLength(1));
    });

    test('signale une date changée', () {
      final diff = UpstreamDiff.between(
        base: snapshot([alpha], scheduledAt: DateTime(2026, 8, 2, 10)),
        mine: copy([alpha], scheduledAt: DateTime(2026, 8, 2, 10)),
        source: source([alpha], scheduledAt: DateTime(2026, 8, 9, 10)),
      );

      final change = diff.changes.whereType<ScheduleChangedUpstream>().single;
      expect(change.scheduledAt, DateTime(2026, 8, 9, 10));
    });

    test('ne dit rien quand la source n\'a pas bougé', () {
      final diff = UpstreamDiff.between(
        base: snapshot([alpha, beta]),
        mine: copy([alpha, beta]),
        source: source([alpha, beta]),
      );

      expect(diff.isEmpty, isTrue);
    });

    test('reste muet sur la tonalité d\'un chant présent deux fois', () {
      // Appariement ambigu : mieux vaut ne rien dire que deviner lequel des
      // deux exemplaires l'auteur a transposé.
      final diff = UpstreamDiff.between(
        base: snapshot([alpha, alpha]),
        mine: copy([alpha, alpha]),
        source: source([alpha, alpha.transposed(4)]),
      );

      expect(diff.changes.whereType<TranspositionChangedUpstream>(), isEmpty);
    });
  });

  group('UpstreamDiff — sans instantané de base', () {
    test('se déclare approximatif', () {
      final diff = UpstreamDiff.between(
        base: null,
        mine: copy([alpha]),
        source: source([alpha, beta]),
      );

      expect(diff.isApproximate, isTrue);
      expect(diff.changes.whereType<SongAddedUpstream>(), hasLength(1));
    });

    test('prend mes propres retraits pour des ajouts de l\'auteur', () {
      // La limite assumée du repli, et la raison pour laquelle l'écran doit
      // l'annoncer : sans base, les deux sont indistinguables.
      final diff = UpstreamDiff.between(
        base: null,
        mine: copy([alpha]),
        source: source([alpha, beta]),
      );

      expect(diff.changes.single, isA<SongAddedUpstream>());
    });
  });

  group('UpstreamDiff.applyTo', () {
    test('n\'applique que ce qui est retenu', () {
      final mine = copy([alpha, beta]);
      final diff = UpstreamDiff.between(
        base: snapshot([alpha, beta]),
        mine: mine,
        source: source([
          alpha,
          beta,
          gamma,
        ], scheduledAt: DateTime(2026, 9, 6, 10)),
      );

      final added = diff.changes.whereType<SongAddedUpstream>().single;
      final merged = diff.applyTo(mine, selected: {added.id});

      expect(merged.entries.map((e) => e.songId), [
        alpha.id,
        beta.id,
        gamma.id,
      ]);
      // La date n'était pas cochée : elle ne bouge pas.
      expect(merged.scheduledAt, mine.scheduledAt);
    });

    test('renumérote les positions après coup', () {
      final mine = copy([alpha, beta, gamma]);
      final diff = UpstreamDiff.between(
        base: snapshot([alpha, beta, gamma]),
        mine: mine,
        source: source([alpha, gamma]),
      );

      final merged = diff.applyTo(
        mine,
        selected: diff.changes.map((c) => c.id).toSet(),
      );

      expect(merged.entries.map((e) => e.songId), [alpha.id, gamma.id]);
      expect(merged.entries.map((e) => e.position), [0, 1]);
    });

    test('garde mes propres ajouts en adoptant l\'ordre de la source', () {
      // Adopter un ordre ne veut pas dire perdre ce que la source ignore.
      final mine = copy([alpha, beta, delta]);
      final diff = UpstreamDiff.between(
        base: snapshot([alpha, beta]),
        mine: mine,
        source: source([beta, alpha]),
      );

      final order = diff.changes.whereType<OrderChangedUpstream>().single;
      final merged = diff.applyTo(mine, selected: {order.id});

      expect(merged.entries.map((e) => e.songId), [
        beta.id,
        alpha.id,
        delta.id,
      ]);
    });

    test('conserve le lien amont', () {
      final mine = copy([alpha]);
      final diff = UpstreamDiff.between(
        base: snapshot([alpha]),
        mine: mine,
        source: source([alpha, beta]),
      );

      final merged = diff.applyTo(
        mine,
        selected: diff.changes.map((c) => c.id).toSet(),
      );

      expect(merged.upstream, mine.upstream);
    });
  });
}

final alpha = _Song('11111111-1111-4111-8111-111111111111');
final beta = _Song('22222222-2222-4222-8222-222222222222');
final gamma = _Song('33333333-3333-4333-8333-333333333333');
final delta = _Song('44444444-4444-4444-8444-444444444444');

final copyId = UuidValue.parse('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa');
final sourceId = UuidValue.parse('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb');

/// Un chant, éventuellement transposé. Sert à écrire les cas en termes de
/// chants plutôt que d'entrées, puisque c'est ainsi que les côtés s'apparient.
class _Song {
  final UuidValue id;
  final int? semitones;

  _Song(String id) : id = UuidValue.parse(id), semitones = null;
  _Song._(this.id, this.semitones);

  _Song transposed(int semitones) => _Song._(id, semitones);
}

extension on _Song {
  UuidValue get songId => id;
}

int _entrySeed = 0;

SongListEntry _entry(_Song song, int position) {
  // Identifiants distincts à chaque appel : côté source et côté copie ils
  // n'ont aucune raison de coïncider, et un test qui les ferait coïncider
  // masquerait un appariement fautif par identifiant.
  _entrySeed++;
  return SongListEntry(
    id: UuidValue.parse(
      '00000000-0000-4000-8000-${_entrySeed.toString().padLeft(12, '0')}',
    ),
    songId: song.songId,
    position: position,
    savedSemitones: song.semitones,
  );
}

List<SongListEntry> _entries(List<_Song> songs) => [
  for (var i = 0; i < songs.length; i++) _entry(songs[i], i),
];

// ignore: library_private_types_in_public_api
UpstreamSnapshot snapshot(List<_Song> songs, {DateTime? scheduledAt}) {
  return UpstreamSnapshot(
    songListId: copyId,
    sourceVersion: 3,
    title: 'Dimanche',
    scheduledAt: scheduledAt ?? DateTime(2026, 8, 2, 10),
    entries: _entries(songs),
    capturedAt: DateTime(2026, 7, 21),
  );
}

// ignore: library_private_types_in_public_api
SongList copy(List<_Song> songs, {DateTime? scheduledAt}) {
  return SongList(
    id: copyId,
    scheduledAt: scheduledAt ?? DateTime(2026, 8, 2, 10),
    createdAt: DateTime(2026, 7, 21),
    entries: _entries(songs),
    version: 1,
    upstream: UpstreamLink(sourceListId: sourceId, sourceVersion: 3),
  );
}

// ignore: library_private_types_in_public_api
SongList source(List<_Song> songs, {DateTime? scheduledAt}) {
  return SongList(
    id: sourceId,
    scheduledAt: scheduledAt ?? DateTime(2026, 8, 2, 10),
    createdAt: DateTime(2026, 7, 21),
    entries: _entries(songs),
    version: 5,
  );
}
