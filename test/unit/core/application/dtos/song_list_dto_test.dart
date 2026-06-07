import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';

void main() {
  // savedSemitones (la tonalité enregistrée par chant dans une liste) traverse
  // toDomain/fromDomain à chaque sauvegarde de liste. toDomain reconstruit les
  // entrées de zéro : si le champ n'y est pas propagé, la tonalité est effacée
  // silencieusement. Ces tests verrouillent ce round-trip.
  group('SongListDto savedSemitones round-trip', () {
    const listId = '00000000-0000-4000-a000-000000000001';
    const entryId1 = '00000000-0000-4000-b000-000000000001';
    const entryId2 = '00000000-0000-4000-b000-000000000002';
    const songId1 = '00000000-0000-4000-9000-000000000001';
    const songId2 = '00000000-0000-4000-9000-000000000002';

    SongListDto buildDto(int? saved1, int? saved2) => SongListDto(
      id: listId,
      scheduledAt: DateTime(2025, 3, 16, 10),
      createdAt: DateTime(2025, 3, 10),
      entries: [
        SongListEntryDto(
          id: entryId1,
          songId: songId1,
          position: 0,
          savedSemitones: saved1,
          songCode: 'C001',
          songName: 'Song 1',
        ),
        SongListEntryDto(
          id: entryId2,
          songId: songId2,
          position: 1,
          savedSemitones: saved2,
          songCode: 'C002',
          songName: 'Song 2',
        ),
      ],
    );

    test('toDomain conserve savedSemitones (y compris null)', () {
      final domain = buildDto(3, null).toDomain();

      expect(domain.entries[0].savedSemitones, 3);
      expect(domain.entries[1].savedSemitones, isNull);
    });

    test('fromDomain conserve savedSemitones', () {
      final domain = buildDto(-2, 5).toDomain();
      final songInfo = {
        for (final e in domain.entries) e.songId: (code: 'X', name: 'Y'),
      };

      final dto = SongListDto.fromDomain(domain, songInfo);
      final byId = {for (final e in dto.entries) e.id: e};

      expect(byId[entryId1]!.savedSemitones, -2);
      expect(byId[entryId2]!.savedSemitones, 5);
    });

    test('round-trip DTO -> domain -> DTO préserve la tonalité', () {
      final domain = buildDto(7, null).toDomain();
      final songInfo = {
        for (final e in domain.entries) e.songId: (code: 'X', name: 'Y'),
      };

      final roundTripped = SongListDto.fromDomain(domain, songInfo);
      final byId = {for (final e in roundTripped.entries) e.id: e};

      expect(byId[entryId1]!.savedSemitones, 7);
      expect(byId[entryId2]!.savedSemitones, isNull);
    });
  });
}
