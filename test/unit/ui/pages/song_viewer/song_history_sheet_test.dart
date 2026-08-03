import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/core/domain/model/song_schedule.dart';
import 'package:songbook/ui/pages/song_viewer/widgets/song_history.sheet.dart';

/// Le panneau est le seul endroit qui donne les dates en entier : ailleurs
/// l'app se contente d'un « il y a trois semaines ».
void main() {
  final now = DateTime(2026, 8, 3, 14, 0);

  Future<void> pump(WidgetTester tester, SongSchedule schedule) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SongHistorySheet(
            songName: 'Amazing Grace',
            schedule: schedule,
            now: now,
          ),
        ),
      ),
    );
  }

  testWidgets('le dit quand un chant n\'a jamais été pris', (tester) async {
    await pump(tester, SongSchedule.never);

    expect(find.byKey(const Key('songHistoryEmpty')), findsOneWidget);
  });

  testWidgets('déroule les dates passées, la plus récente d\'abord', (
    tester,
  ) async {
    await pump(
      tester,
      SongSchedule.from([
        DateTime(2026, 6, 8, 10, 0),
        DateTime(2026, 7, 13, 10, 0),
      ], now: now),
    );

    expect(find.text('Déjà chanté'), findsOneWidget);
    expect(find.text('Lun 13 juil 2026, 10:00'), findsOneWidget);
    expect(find.text('Lun 8 juin 2026, 10:00'), findsOneWidget);
    expect(find.text('il y a 3 semaines'), findsOneWidget);

    final dates = tester
        .widgetList<Text>(find.textContaining('2026, 10:00'))
        .map((text) => text.data)
        .toList();
    expect(dates.first, 'Lun 13 juil 2026, 10:00');
  });

  testWidgets('sépare ce qui est déjà prévu de ce qui a été chanté', (
    tester,
  ) async {
    await pump(
      tester,
      SongSchedule.from([
        DateTime(2026, 7, 13, 10, 0),
        DateTime(2026, 8, 9, 10, 0),
      ], now: now),
    );

    expect(find.text('Déjà prévu'), findsOneWidget);
    expect(find.text('Dim 9 août 2026, 10:00'), findsOneWidget);
    expect(find.text('Déjà chanté'), findsOneWidget);
  });
}
