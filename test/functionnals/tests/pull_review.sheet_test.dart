import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/core/application/services/song_list_pull.service.dart';
import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/upstream_diff.dart';
import 'package:songbook/core/domain/model/upstream_link.dart';
import 'package:songbook/core/domain/model/upstream_snapshot.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/infrastructure/song/in_memory.song.repository.dart';
import 'package:songbook/infrastructure/song/providers/song.repository_provider.dart';
import 'package:songbook/ui/pages/song_list_pull/pull_review.sheet.dart';

/// La feuille modale d'arbitrage.
///
/// Sa règle centrale : ce qui **défait un travail personnel** arrive décoché.
/// Tout cocher par défaut ferait perdre une transposition ou un rangement d'un
/// simple appui sur « Reprendre », sans que rien ne l'ait signalé.
void main() {
  Future<void> pumpReview(WidgetTester tester, PullPreview preview) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          songRepositoryProvider.overrideWithValue(InMemorySongRepository()),
        ],
        child: MaterialApp(
          home: Scaffold(body: PullReviewSheet(preview: preview)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('PullReviewSheet', () {
    testWidgets('coche par défaut les changements sans conséquence', (
      tester,
    ) async {
      await pumpReview(tester, preview(mineSemitones: null));

      final boxes = tester
          .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
          .toList();

      expect(boxes, isNotEmpty);
      expect(boxes.every((b) => b.value == true), isTrue);
    });

    testWidgets('laisse décoché ce qui écrase ma tonalité', (tester) async {
      // J'avais choisi -1, l'auteur passe à +2 : appliquer sans le dire
      // effacerait mon réglage.
      await pumpReview(tester, preview(mineSemitones: -1));

      final boxes = tester
          .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
          .toList();

      expect(boxes.any((b) => b.value == false), isTrue);
      expect(
        find.text('Remplace la tonalité que vous aviez choisie'),
        findsOneWidget,
      );
    });

    testWidgets('propose de ne rien reprendre quand tout est décoché', (
      tester,
    ) async {
      // Décocher jusqu'au bout reste une décision valide : la base avance
      // quand même, et le bouton doit le dire sans détour.
      await pumpReview(tester, preview(mineSemitones: null));

      expect(find.text('Ne rien reprendre'), findsNothing);

      await tester.tap(find.byType(CheckboxListTile).first);
      await tester.pumpAndSettle();

      expect(find.text('Ne rien reprendre'), findsOneWidget);
    });

    testWidgets(
      'arrive déjà à « ne rien reprendre » quand tout est conflictuel',
      (tester) async {
        await pumpReview(tester, preview(mineSemitones: -1));

        expect(find.text('Ne rien reprendre'), findsOneWidget);
      },
    );

    testWidgets('annonce une comparaison approchée', (tester) async {
      // Sans instantané de base, les modifications de l'utilisateur passent
      // pour des changements de l'auteur : le taire ferait appliquer n'importe
      // quoi en confiance.
      await pumpReview(tester, preview(mineSemitones: null, withBase: false));

      expect(find.byKey(const Key('approximateDiffWarning')), findsOneWidget);
    });

    testWidgets('n\'annonce rien quand la comparaison est exacte', (
      tester,
    ) async {
      await pumpReview(tester, preview(mineSemitones: null));

      expect(find.byKey(const Key('approximateDiffWarning')), findsNothing);
    });
  });
}

final copyId = UuidValue.parse('11111111-1111-4111-8111-111111111111');
final sourceId = UuidValue.parse('22222222-2222-4222-8222-222222222222');
final songId = UuidValue.parse('33333333-3333-4333-8333-333333333333');

int _seed = 0;

SongListEntry _entry(int? semitones) {
  _seed++;
  return SongListEntry(
    id: UuidValue.parse(
      '00000000-0000-4000-8000-${_seed.toString().padLeft(12, '0')}',
    ),
    songId: songId,
    position: 0,
    savedSemitones: semitones,
  );
}

/// L'auteur transpose le chant à +2 ; [mineSemitones] dit ce que j'en avais
/// fait de mon côté.
PullPreview preview({required int? mineSemitones, bool withBase = true}) {
  final base = UpstreamSnapshot(
    songListId: copyId,
    sourceVersion: 3,
    title: 'Dimanche',
    scheduledAt: DateTime(2026, 8, 2, 10),
    entries: [_entry(null)],
    capturedAt: DateTime(2026, 7, 21),
  );

  final copy = SongList(
    id: copyId,
    scheduledAt: DateTime(2026, 8, 2, 10),
    createdAt: DateTime(2026, 7, 21),
    entries: [_entry(mineSemitones)],
    version: 1,
    upstream: UpstreamLink(sourceListId: sourceId, sourceVersion: 3),
  );

  final source = SongList(
    id: sourceId,
    scheduledAt: DateTime(2026, 8, 2, 10),
    createdAt: DateTime(2026, 7, 21),
    entries: [_entry(2)],
    version: 5,
  );

  return PullPreview(
    copy: copy,
    source: source,
    diff: UpstreamDiff.between(
      base: withBase ? base : null,
      mine: copy,
      source: source,
    ),
  );
}
