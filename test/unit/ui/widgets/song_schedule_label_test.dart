import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/core/domain/model/song_schedule.dart';
import 'package:songbook/ui/widgets/song_schedule_label.widget.dart';

/// La ligne ne dit qu'une chose à la fois : celle qui décide. Un chant déjà
/// prévu ailleurs se reprend rarement, même s'il a été chanté il y a longtemps.
void main() {
  final now = DateTime(2026, 8, 3, 14, 0);

  Future<void> pump(WidgetTester tester, SongSchedule schedule) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SongScheduleLabel(schedule: schedule, now: now),
        ),
      ),
    );
  }

  testWidgets('signale un chant jamais pris', (tester) async {
    await pump(tester, SongSchedule.never);

    expect(find.text('Jamais chanté'), findsOneWidget);
  });

  testWidgets('dit depuis quand un chant n\'a pas été pris', (tester) async {
    await pump(
      tester,
      SongSchedule.from([DateTime(2026, 7, 13, 10, 0)], now: now),
    );

    expect(find.text('Chanté il y a 3 semaines'), findsOneWidget);
  });

  testWidgets('annonce d\'abord qu\'un chant est déjà prévu', (tester) async {
    await pump(
      tester,
      SongSchedule.from([
        DateTime(2026, 7, 13, 10, 0),
        DateTime(2026, 8, 9, 10, 0),
      ], now: now),
    );

    expect(find.text('Déjà prévu Dim 9 août'), findsOneWidget);
    expect(find.textContaining('Chanté'), findsNothing);
  });
}
