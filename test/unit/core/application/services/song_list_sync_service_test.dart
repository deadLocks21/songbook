import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/core/application/services/song_list_sync.service.dart';
import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/song_list.repository.dart';
import 'package:songbook/infrastructure/song_list/in_memory.remote_song_list.repository.dart';
import 'package:songbook/infrastructure/song_list/in_memory.song_list.repository.dart';

/// Deux appareils d'un même utilisateur, un seul serveur : la configuration
/// que la synchro doit rendre cohérente.
///
/// Les tests utilisent les vraies implémentations en mémoire (locale et
/// distante) plutôt que des bouchons, pour que les règles de version et de
/// pierres tombales soient réellement exercées.
void main() {
  const baseUrl = 'https://songbook.test';

  late InMemoryRemoteSongListRepository server;
  late InMemorySongListRepository deviceA;
  late InMemorySongListRepository deviceB;
  late SongListSyncService syncA;
  late SongListSyncService syncB;

  setUp(() {
    server = InMemoryRemoteSongListRepository();
    deviceA = InMemorySongListRepository();
    deviceB = InMemorySongListRepository();
    syncA = SongListSyncService(deviceA, server);
    syncB = SongListSyncService(deviceB, server);
  });

  group('SongListSyncService', () {
    test('pousse une liste créée localement et retient sa version', () async {
      await deviceA.addSongList(songList(scheduledAt: DateTime(2026, 8, 2)));

      await syncA.sync(baseUrl);

      final stored = (await deviceA.getAllSongLists()).single;
      expect(stored.version, 1);
      expect(await deviceA.getPendingPush(), isEmpty);
    });

    test('rend une liste créée sur A visible sur B', () async {
      await deviceA.addSongList(songList(scheduledAt: DateTime(2026, 8, 2)));
      await syncA.sync(baseUrl);

      await syncB.sync(baseUrl);

      final onB = (await deviceB.getAllSongLists()).single;
      expect(onB.id, listId);
      expect(onB.scheduledAt, DateTime(2026, 8, 2));
      expect(onB.entries, hasLength(1));
      expect(onB.version, 1);
    });

    test('propage une modification faite sur A vers B', () async {
      await deviceA.addSongList(songList(scheduledAt: DateTime(2026, 8, 2)));
      await syncA.sync(baseUrl);
      await syncB.sync(baseUrl);

      final onA = (await deviceA.getAllSongLists()).single;
      await deviceA.updateSongList(
        onA.copyWith(scheduledAt: DateTime(2026, 8, 9)),
      );
      await syncA.sync(baseUrl);
      await syncB.sync(baseUrl);

      final onB = (await deviceB.getAllSongLists()).single;
      expect(onB.scheduledAt, DateTime(2026, 8, 9));
      expect(onB.version, 2);
    });

    test('propage une suppression faite sur A vers B', () async {
      await deviceA.addSongList(songList(scheduledAt: DateTime(2026, 8, 2)));
      await syncA.sync(baseUrl);
      await syncB.sync(baseUrl);

      await deviceA.deleteSongList(listId);
      await syncA.sync(baseUrl);
      await syncB.sync(baseUrl);

      expect(await deviceA.getAllSongLists(), isEmpty);
      expect(await deviceB.getAllSongLists(), isEmpty);
      // La ligne locale part vraiment une fois la suppression propagée.
      expect(await deviceA.getPendingDeletions(), isEmpty);
    });

    test(
      'ne supprime pas localement une liste absente du serveur mais jamais poussée',
      () async {
        // Le cas que les pierres tombales évitent : sans elles, une liste toute
        // neuve serait prise pour une liste supprimée ailleurs.
        await deviceA.addSongList(songList(scheduledAt: DateTime(2026, 8, 2)));

        await syncA.sync(baseUrl);

        expect(await deviceA.getAllSongLists(), hasLength(1));
      },
    );

    test(
      'garde la copie locale quand une liste supprimée ailleurs a été modifiée ici',
      () async {
        await deviceA.addSongList(songList(scheduledAt: DateTime(2026, 8, 2)));
        await syncA.sync(baseUrl);
        await syncB.sync(baseUrl);

        // A supprime pendant que B, hors-ligne, retouche la même liste.
        await deviceA.deleteSongList(listId);
        await syncA.sync(baseUrl);

        final onB = (await deviceB.getAllSongLists()).single;
        await deviceB.updateSongList(
          onB.copyWith(scheduledAt: DateTime(2026, 8, 16)),
        );

        await syncB.sync(baseUrl);

        // Le travail de B survit et ressuscite la liste côté serveur.
        final revived = (await deviceB.getAllSongLists()).single;
        expect(revived.scheduledAt, DateTime(2026, 8, 16));

        await syncA.sync(baseUrl);
        expect(await deviceA.getAllSongLists(), hasLength(1));
      },
    );

    test('rejoue l\'édition locale quand le canon a bougé entre-temps', () async {
      await deviceA.addSongList(songList(scheduledAt: DateTime(2026, 8, 2)));
      await syncA.sync(baseUrl);
      await syncB.sync(baseUrl);

      // A écrit deux fois : B travaille désormais sur une version périmée.
      final onA = (await deviceA.getAllSongLists()).single;
      await deviceA.updateSongList(
        onA.copyWith(scheduledAt: DateTime(2026, 8, 9)),
      );
      await syncA.sync(baseUrl);

      final onB = (await deviceB.getAllSongLists()).single;
      await deviceB.updateSongList(
        onB.copyWith(scheduledAt: DateTime(2026, 8, 23)),
      );

      await syncB.sync(baseUrl);

      // L'édition la plus récente l'emporte, sans erreur remontée à l'appelant.
      await syncA.sync(baseUrl);
      final finalOnA = (await deviceA.getAllSongLists()).single;
      expect(finalOnA.scheduledAt, DateTime(2026, 8, 23));
    });

    test('n\'écrase pas une modification locale non poussée par le canon', () async {
      await deviceA.addSongList(songList(scheduledAt: DateTime(2026, 8, 2)));
      await syncA.sync(baseUrl);
      await syncB.sync(baseUrl);

      // B modifie sans pouvoir pousser : un pull seul ne doit rien perdre.
      final onB = (await deviceB.getAllSongLists()).single;
      await deviceB.updateSongList(
        onB.copyWith(scheduledAt: DateTime(2026, 8, 30)),
      );

      await pullOnly(deviceB, server, baseUrl);

      final stillOnB = (await deviceB.getAllSongLists()).single;
      expect(stillOnB.scheduledAt, DateTime(2026, 8, 30));
      expect(await deviceB.getPendingPush(), hasLength(1));
    });

    test(
      'garde à pousser une modification enregistrée pendant l\'envoi',
      () async {
        await deviceA.addSongList(songList(scheduledAt: DateTime(2026, 8, 2)));
        await syncA.sync(baseUrl);

        // On rejoue la séquence d'un enregistrement qui tombe pendant que
        // l'envoi précédent est encore en vol : le push lit la révision 1,
        // l'utilisateur sauvegarde (révision 2), puis l'envoi se termine.
        final onA = (await deviceA.getAllSongLists()).single;
        await deviceA.updateSongList(
          onA.copyWith(scheduledAt: DateTime(2026, 8, 9)),
        );
        final inFlight = (await deviceA.getPendingPush()).single;

        await deviceA.updateSongList(
          onA.copyWith(scheduledAt: DateTime(2026, 8, 16)),
        );
        await deviceA.markSynced(
          inFlight.list.id,
          2,
          revision: inFlight.revision,
        );

        // La modification arrivée entre-temps n'est pas soldée par erreur.
        expect(await deviceA.getPendingPush(), hasLength(1));

        await syncA.sync(baseUrl);
        await syncB.sync(baseUrl);
        expect(
          (await deviceB.getAllSongLists()).single.scheduledAt,
          DateTime(2026, 8, 16),
        );
      },
    );

    test('ne laisse rien à pousser après une synchro réussie', () async {
      await deviceA.addSongList(songList(scheduledAt: DateTime(2026, 8, 2)));
      await syncA.sync(baseUrl);

      expect(await deviceA.getPendingPush(), isEmpty);
      expect(await deviceA.getPendingDeletions(), isEmpty);
    });
  });
}

final listId = UuidValue.parse('11111111-1111-4111-8111-111111111111');
final entryId = UuidValue.parse('22222222-2222-4222-8222-222222222222');
final songId = UuidValue.parse('33333333-3333-4333-8333-333333333333');

SongList songList({required DateTime scheduledAt}) {
  return SongList(
    id: listId,
    scheduledAt: scheduledAt,
    createdAt: DateTime(2026, 7, 21),
    entries: [SongListEntry(id: entryId, songId: songId, position: 0)],
  );
}

/// Tire l'état du serveur sans rien pousser, pour isoler le comportement du
/// pull (ce que fait un appareil qui a échoué à pousser juste avant).
Future<void> pullOnly(
  SongListRepository local,
  InMemoryRemoteSongListRepository server,
  String baseUrl,
) async {
  final snapshot = await server.fetchAll(baseUrl);
  for (final songList in snapshot.lists) {
    await local.upsertFromRemote(songList);
  }
  for (final id in snapshot.deletedIds) {
    await local.applyRemoteDeletion(id);
  }
}
