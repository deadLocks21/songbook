import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/ui/pages/chord_pro_viewer/chord_pro_viewer.page.dart';

void main() {
  group('ChordProTransposeControls', () {
    Future<void> pump(
      WidgetTester tester, {
      required int semitones,
      String? originalKey,
      ValueChanged<int>? onTranspose,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChordProTransposeControls(
              semitones: semitones,
              originalKey: originalKey,
              onTranspose: onTranspose ?? (_) {},
            ),
          ),
        ),
      );
    }

    testWidgets('affiche la tonalité d\'origine à zéro demi-ton', (
      tester,
    ) async {
      await pump(tester, semitones: 0, originalKey: 'C');

      expect(find.text('C'), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });

    testWidgets('affiche la tonalité obtenue vers le haut', (tester) async {
      await pump(tester, semitones: 2, originalKey: 'C');

      expect(find.text('D'), findsOneWidget);
      expect(find.text('+2'), findsNothing);
    });

    testWidgets('affiche la tonalité obtenue vers le bas', (tester) async {
      await pump(tester, semitones: -1, originalKey: 'C');

      expect(find.text('B'), findsOneWidget);
      expect(find.text('-1'), findsNothing);
    });

    testWidgets('conserve la qualité mineure de la tonalité', (tester) async {
      await pump(tester, semitones: 3, originalKey: 'Am');

      expect(find.text('Cm'), findsOneWidget);
    });

    testWidgets('retombe sur +X quand aucune tonalité n\'est connue', (
      tester,
    ) async {
      await pump(tester, semitones: 2);

      expect(find.text('+2'), findsOneWidget);
    });

    testWidgets('retombe sur 0 sans tonalité ni transposition', (tester) async {
      await pump(tester, semitones: 0);

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('retombe sur +X quand la tonalité n\'est pas une lettre', (
      tester,
    ) async {
      // Notation Nashville : pas de tonalité lettre exploitable.
      await pump(tester, semitones: 2, originalKey: '1');

      expect(find.text('+2'), findsOneWidget);
    });

    testWidgets('les boutons remontent le delta de transposition', (
      tester,
    ) async {
      final deltas = <int>[];
      await pump(
        tester,
        semitones: 0,
        originalKey: 'C',
        onTranspose: deltas.add,
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.tap(find.byIcon(Icons.remove));

      expect(deltas, [1, -1]);
    });
  });
}
