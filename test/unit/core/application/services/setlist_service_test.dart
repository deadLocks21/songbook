import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/core/application/services/setlist.service.dart';
import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/upstream_link.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/infrastructure/song/in_memory.song.repository.dart';
import 'package:songbook/infrastructure/song_list/in_memory.song_list.repository.dart';

/// L'enregistrement d'une liste passe par un DTO d'UI qui, volontairement, ne
/// transporte pas tout : ni la version serveur, ni le lien amont. Ce que le DTO
/// ne dit pas doit être repris de la copie locale — sinon chaque
/// enregistrement effacerait ce qu'il ignore.
void main() {
  late InMemorySongListRepository local;
  late SetlistService service;

  setUp(() {
    local = InMemorySongListRepository();
    service = SetlistService(local, InMemorySongRepository());
  });

  group('SetlistService.save', () {
    test('conserve le lien amont d\'une liste suivie', () async {
      // Le piège : sans reprise explicite, la prochaine écriture partirait sans
      // `sourceListId` — c'est-à-dire désabonnerait la liste dès la première
      // modification, sans que rien ne le signale à l'utilisateur.
      await local.addSongList(followedList());

      await service.save(editedDto());

      final saved = (await local.getAllSongLists()).single;
      expect(saved.upstream?.sourceListId, sourceId);
      expect(saved.upstream?.sourceVersion, 7);
    });

    test('conserve la version serveur et le titre', () async {
      await local.addSongList(followedList());

      await service.save(editedDto());

      final saved = (await local.getAllSongLists()).single;
      expect(saved.version, 3);
      expect(saved.title, 'Dimanche');
    });

    test('applique bien la modification demandée', () async {
      await local.addSongList(followedList());

      await service.save(editedDto());

      final saved = (await local.getAllSongLists()).single;
      expect(saved.scheduledAt, DateTime(2026, 9, 6, 10));
    });

    test('ne fabrique pas de lien amont sur une liste ordinaire', () async {
      await local.addSongList(
        SongList(
          id: listId,
          scheduledAt: DateTime(2026, 8, 2, 10),
          createdAt: DateTime(2026, 7, 21),
          entries: const [],
          version: 3,
        ),
      );

      await service.save(editedDto());

      expect((await local.getAllSongLists()).single.upstream, isNull);
    });
  });
}

final listId = UuidValue.parse('11111111-1111-4111-8111-111111111111');
final sourceId = UuidValue.parse('55555555-5555-4555-8555-555555555555');

SongList followedList() {
  return SongList(
    id: listId,
    scheduledAt: DateTime(2026, 8, 2, 10),
    createdAt: DateTime(2026, 7, 21),
    entries: const [],
    title: 'Dimanche',
    version: 3,
    upstream: UpstreamLink(sourceListId: sourceId, sourceVersion: 7),
  );
}

/// Ce que l'écran d'édition renvoie : la date a changé, et rien d'autre n'est
/// connu de lui.
SongListDto editedDto() {
  return SongListDto(
    id: listId.value,
    scheduledAt: DateTime(2026, 9, 6, 10),
    createdAt: DateTime(2026, 7, 21),
    entries: const [],
  );
}
