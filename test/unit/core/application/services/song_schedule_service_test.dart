import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/core/application/services/song_schedule.service.dart';

/// L'historique se lit dans les listes de l'appareil : un chant est « déjà
/// pris » parce qu'une liste le porte, à sa date.
void main() {
  const service = SongScheduleService();
  final now = DateTime(2026, 8, 3, 14, 0);

  SongListDto setlist(String id, DateTime scheduledAt, List<String> songIds) {
    return SongListDto(
      id: id,
      scheduledAt: scheduledAt,
      createdAt: DateTime(2026, 1, 1),
      entries: [
        for (var i = 0; i < songIds.length; i++)
          SongListEntryDto(
            id: '$id-entry-$i',
            songId: songIds[i],
            position: i,
            songCode: 'C00$i',
            songName: 'Chant $i',
          ),
      ],
    );
  }

  group('SongScheduleService.bySongId', () {
    test('rassemble les dates d\'un chant à travers les listes', () {
      final schedules = service.bySongId([
        setlist('l1', DateTime(2026, 6, 8, 10, 0), ['song-a', 'song-b']),
        setlist('l2', DateTime(2026, 7, 13, 10, 0), ['song-a']),
        setlist('l3', DateTime(2026, 8, 9, 10, 0), ['song-a']),
      ], now: now);

      expect(schedules['song-a']!.lastSungAt, DateTime(2026, 7, 13, 10, 0));
      expect(schedules['song-a']!.nextPlannedAt, DateTime(2026, 8, 9, 10, 0));
      expect(schedules['song-b']!.lastSungAt, DateTime(2026, 6, 8, 10, 0));
    });

    test('ignore un chant qu\'aucune liste ne mentionne', () {
      final schedules = service.bySongId([
        setlist('l1', DateTime(2026, 6, 8, 10, 0), ['song-a']),
      ], now: now);

      expect(schedules.containsKey('song-b'), isFalse);
    });

    test('écarte la liste en cours d\'édition', () {
      // Sans quoi les chants déjà posés dans cette liste s'annonceraient « déjà
      // prévu », en pointant celle que l'utilisateur a sous les yeux.
      final schedules = service.bySongId(
        [
          setlist('en-cours', DateTime(2026, 8, 9, 10, 0), ['song-a']),
          setlist('l2', DateTime(2026, 7, 13, 10, 0), ['song-a']),
        ],
        now: now,
        excludingListId: 'en-cours',
      );

      expect(schedules['song-a']!.nextPlannedAt, isNull);
      expect(schedules['song-a']!.lastSungAt, DateTime(2026, 7, 13, 10, 0));
    });

    test('rend une map vide quand il n\'y a aucune liste', () {
      expect(service.bySongId([], now: now), isEmpty);
    });
  });
}
