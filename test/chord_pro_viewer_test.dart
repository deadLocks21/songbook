import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/ui/pages/chord_pro_viewer/chord_pro_viewer.page.dart';

void main() {
  const source = '''
{title: Test Song}
{key: G}
[G]Hello [C]world
''';

  testWidgets('renders title, lyrics and chords', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ChordProViewerPage(source: source)),
    );

    expect(find.text('Test Song'), findsOneWidget);
    expect(find.text('G'), findsWidgets);
    expect(find.text('C'), findsWidgets);
    expect(find.textContaining('Hello'), findsOneWidget);
  });

  testWidgets('transposes chords up by tapping +', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ChordProViewerPage(source: source)),
    );

    expect(find.text('G'), findsWidgets);

    // La transposition se fait via un panneau ouvert depuis l'AppBar.
    await tester.tap(find.byTooltip('Transposer'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Transposer +1'));
    await tester.pump();

    // G + 2 semitones (par défaut le pas est de 1) -> G#/Ab on first tap.
    expect(find.text('+1'), findsOneWidget);
    expect(find.text('G'), findsNothing);
  });
}
