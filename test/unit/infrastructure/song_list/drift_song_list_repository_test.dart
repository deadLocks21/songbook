import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/upstream_link.dart';
import 'package:songbook/core/domain/model/upstream_snapshot.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/infrastructure/song/drift/drift_database.dart';
import 'package:songbook/infrastructure/song_list/drift.song_list.repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Vérifie l'état de synchro tel qu'il est réellement stocké en SQLite : c'est
/// là que vivent les règles qui protègent le travail hors-ligne (compteur
/// d'écritures en attente, pierres tombales locales, refus d'écraser une
/// modification non poussée).
void main() {
  late Database db;
  late DriftSongListRepository repository;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);
    await AppDatabase.createSongListTables(db);
    repository = DriftSongListRepository(db);
  });

  tearDown(() => db.close());

  group('DriftSongListRepository', () {
    test('marque une liste créée comme restant à pousser', () async {
      await repository.addSongList(songList());

      final pending = await repository.getPendingPush();
      expect(pending, hasLength(1));
      expect(pending.single.list.version, isNull);
      expect(pending.single.revision, 1);
    });

    test('solde ce qui a été poussé', () async {
      await repository.addSongList(songList());
      final pending = await repository.getPendingPush();

      await repository.markSynced(listId, 1, revision: pending.single.revision);

      expect(await repository.getPendingPush(), isEmpty);
      expect((await repository.getSongListById(listId))!.version, 1);
    });

    test(
      'retient la version serveur mais garde à pousser ce qui a été écrit pendant l\'envoi',
      () async {
        await repository.addSongList(songList());
        final inFlight = (await repository.getPendingPush()).single;

        await repository.updateSongList(
          inFlight.list.copyWith(scheduledAt: DateTime(2026, 8, 9)),
        );
        await repository.markSynced(listId, 1, revision: inFlight.revision);

        expect(await repository.getPendingPush(), hasLength(1));
        expect((await repository.getSongListById(listId))!.version, 1);
      },
    );

    test('efface directement une liste jamais poussée', () async {
      await repository.addSongList(songList());

      await repository.deleteSongList(listId);

      expect(await repository.getAllSongLists(), isEmpty);
      // Rien à propager : le serveur n'a jamais connu cette liste.
      expect(await repository.getPendingDeletions(), isEmpty);
    });

    test('garde une trace à propager pour une liste déjà poussée', () async {
      await repository.addSongList(songList());
      await repository.markSynced(listId, 1, revision: 1);

      await repository.deleteSongList(listId);

      expect(await repository.getAllSongLists(), isEmpty);
      expect(await repository.getSongListById(listId), isNull);
      expect(await repository.getPendingDeletions(), [listId]);
      // Une liste en attente de suppression n'est pas à pousser comme contenu.
      expect(await repository.getPendingPush(), isEmpty);
    });

    test('remplace le contenu local par celui du serveur', () async {
      await repository.addSongList(songList());
      await repository.markSynced(listId, 1, revision: 1);

      await repository.upsertFromRemote(
        songList(scheduledAt: DateTime(2026, 9, 6)).copyWith(version: 4),
      );

      final stored = (await repository.getAllSongLists()).single;
      expect(stored.scheduledAt, DateTime(2026, 9, 6));
      expect(stored.version, 4);
      expect(await repository.getPendingPush(), isEmpty);
    });

    test('n\'écrase pas une modification locale non poussée', () async {
      await repository.addSongList(songList());
      await repository.markSynced(listId, 1, revision: 1);
      final stored = (await repository.getSongListById(listId))!;
      await repository.updateSongList(
        stored.copyWith(scheduledAt: DateTime(2026, 8, 9)),
      );

      await repository.upsertFromRemote(
        songList(scheduledAt: DateTime(2026, 9, 6)).copyWith(version: 4),
      );

      final kept = (await repository.getAllSongLists()).single;
      expect(kept.scheduledAt, DateTime(2026, 8, 9));
      expect(await repository.getPendingPush(), hasLength(1));
    });

    test('applique une suppression venue du serveur', () async {
      await repository.addSongList(songList());
      await repository.markSynced(listId, 1, revision: 1);

      await repository.applyRemoteDeletion(listId);

      expect(await repository.getAllSongLists(), isEmpty);
    });

    test(
      'ignore une suppression venue du serveur si la liste a été modifiée ici',
      () async {
        await repository.addSongList(songList());
        await repository.markSynced(listId, 1, revision: 1);
        final stored = (await repository.getSongListById(listId))!;
        await repository.updateSongList(
          stored.copyWith(scheduledAt: DateTime(2026, 8, 9)),
        );

        await repository.applyRemoteDeletion(listId);

        expect(await repository.getAllSongLists(), hasLength(1));
      },
    );

    test('conserve les entrées et leur transposition', () async {
      await repository.addSongList(songList());

      final stored = (await repository.getSongListById(listId))!;
      expect(stored.entries, hasLength(2));
      expect(stored.entries.first.savedSemitones, 2);
      expect(stored.entries.last.savedSemitones, isNull);
      expect(stored.entries.map((e) => e.position), [0, 1]);
    });
  });

  group('DriftSongListRepository — abonnement', () {
    test('conserve le lien amont d\'une copie', () async {
      await repository.addSongList(followingList());

      final stored = (await repository.getSongListById(listId))!;
      expect(stored.upstream?.sourceListId, sourceId);
      expect(stored.upstream?.sourceVersion, 7);
    });

    test('conserve le lien amont à travers une modification', () async {
      // Le piège : une écriture qui oublierait le lien désabonnerait la liste
      // au premier enregistrement, sans que rien ne le signale.
      await repository.addSongList(followingList());
      final stored = (await repository.getSongListById(listId))!;

      await repository.updateSongList(
        stored.copyWith(scheduledAt: DateTime(2026, 9, 6)),
      );

      final updated = (await repository.getSongListById(listId))!;
      expect(updated.upstream?.sourceListId, sourceId);
      expect(updated.upstream?.sourceVersion, 7);
    });

    test('fait avancer le repère quand la copie tire sa source', () async {
      await repository.addSongList(followingList());
      final stored = (await repository.getSongListById(listId))!;

      await repository.updateSongList(
        stored.copyWith(upstream: stored.upstream!.pulledAt(9)),
      );

      final updated = (await repository.getSongListById(listId))!;
      expect(updated.upstream?.sourceVersion, 9);
    });

    test('retrouve la copie faite depuis une source', () async {
      await repository.addSongList(followingList());

      final copy = await repository.findCopyOf(sourceId);

      expect(copy?.id, listId);
    });

    test('ne retrouve rien pour une source jamais suivie', () async {
      await repository.addSongList(songList());

      expect(await repository.findCopyOf(sourceId), isNull);
    });

    test('enregistre et relit l\'instantané de la source', () async {
      await repository.addSongList(followingList());

      await repository.saveUpstreamSnapshot(
        UpstreamSnapshot.of(listId, sourceSongList()),
      );

      final snapshot = await repository.getUpstreamSnapshot(listId);
      expect(snapshot!.sourceVersion, 7);
      expect(snapshot.title, 'Dimanche');
      // Les identifiants sont ceux de la source, pas ceux de la copie : c'est
      // ce qui permettra de diffuser base → amont sans ambiguïté.
      expect(snapshot.entries.map((e) => e.id), [entryId, otherEntryId]);
      expect(snapshot.entries.first.savedSemitones, 2);
    });

    test('remplace l\'instantané précédent au tirage suivant', () async {
      await repository.addSongList(followingList());
      await repository.saveUpstreamSnapshot(
        UpstreamSnapshot.of(listId, sourceSongList()),
      );

      await repository.saveUpstreamSnapshot(
        UpstreamSnapshot.of(listId, sourceSongList(version: 9)),
      );

      final snapshot = await repository.getUpstreamSnapshot(listId);
      expect(snapshot!.sourceVersion, 9);
      expect(snapshot.entries, hasLength(2));
    });

    test('efface l\'instantané avec la liste', () async {
      // Les cascades du schéma ne se déclenchent pas : sqflite n'active pas
      // `PRAGMA foreign_keys`. Sans effacement explicite, l'instantané
      // survivrait à sa liste et serait resservi à une homonyme.
      await repository.addSongList(followingList());
      await repository.saveUpstreamSnapshot(
        UpstreamSnapshot.of(listId, sourceSongList()),
      );

      await repository.purge(listId);

      expect(await repository.getUpstreamSnapshot(listId), isNull);
    });
  });
}

final listId = UuidValue.parse('11111111-1111-4111-8111-111111111111');
final entryId = UuidValue.parse('22222222-2222-4222-8222-222222222222');
final otherEntryId = UuidValue.parse('44444444-4444-4444-8444-444444444444');
final songId = UuidValue.parse('33333333-3333-4333-8333-333333333333');
final sourceId = UuidValue.parse('55555555-5555-4555-8555-555555555555');

SongList songList({DateTime? scheduledAt}) {
  return SongList(
    id: listId,
    scheduledAt: scheduledAt ?? DateTime(2026, 8, 2),
    createdAt: DateTime(2026, 7, 21),
    entries: [
      SongListEntry(
        id: entryId,
        songId: songId,
        position: 0,
        savedSemitones: 2,
      ),
      SongListEntry(id: otherEntryId, songId: songId, position: 1),
    ],
  );
}

/// La même liste, mais copiée de celle de quelqu'un d'autre.
SongList followingList() {
  return songList().copyWith(
    upstream: UpstreamLink(sourceListId: sourceId, sourceVersion: 7),
  );
}

/// La liste d'origine, telle que le serveur la rend.
SongList sourceSongList({int version = 7}) {
  return SongList(
    id: sourceId,
    scheduledAt: DateTime(2026, 8, 2),
    createdAt: DateTime(2026, 7, 21),
    title: 'Dimanche',
    version: version,
    entries: songList().entries,
  );
}
