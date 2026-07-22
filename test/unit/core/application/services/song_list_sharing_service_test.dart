import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/core/application/services/song_list_sharing.service.dart';
import 'package:songbook/core/domain/exceptions/song_list_sync.exception.dart';
import 'package:songbook/core/domain/model/share_link.dart';
import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/song_list_snapshot.dart';
import 'package:songbook/core/domain/model/subscription_result.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/remote_song_list.repository.dart';
import 'package:songbook/infrastructure/song_list/in_memory.song_list.repository.dart';

/// S'abonner à une liste, c'est en repartir avec une copie à soi.
///
/// Les cas qui comptent ne sont pas les erreurs mais les trois façons de ne
/// **pas** dupliquer : son propre lien, une copie déjà faite ici, une copie
/// faite sur un autre appareil. Chacune produirait un doublon si elle était
/// traitée comme un abonnement ordinaire.
void main() {
  const baseUrl = 'https://songbook.test';

  late _StubRemote server;
  late InMemorySongListRepository local;
  late SongListSharingService service;

  setUp(() {
    server = _StubRemote();
    local = InMemorySongListRepository();
    service = SongListSharingService(local, server);
  });

  group('SongListSharingService.follow', () {
    test('duplique la source en une liste à moi', () async {
      server.subscription = subscription(source());

      final outcome = await service.follow(baseUrl, code: 'K7Q2M9XZ');

      expect(outcome.status, FollowStatus.copied);

      final copy = (await local.getAllSongLists()).single;
      expect(copy.id, outcome.listId);
      // Nouvel identifiant : côté serveur celui de la source appartient déjà à
      // quelqu'un, le réutiliser ferait entrer les deux listes en collision.
      expect(copy.id, isNot(sourceId));
      expect(copy.upstream?.sourceListId, sourceId);
      expect(copy.upstream?.sourceVersion, 7);
      // Jamais poussée : son premier envoi doit être une création.
      expect(copy.version, isNull);
    });

    test('ré-identifie les entrées de la copie', () async {
      server.subscription = subscription(source());

      await service.follow(baseUrl, code: 'K7Q2M9XZ');

      final copy = (await local.getAllSongLists()).single;
      expect(copy.entries.map((e) => e.id), isNot(contains(entryId)));
      // Le contenu, lui, est bien repris.
      expect(copy.entries.map((e) => e.songId), [songId, songId]);
      expect(copy.entries.first.savedSemitones, 2);
    });

    test('retient l\'état de la source au moment de la copie', () async {
      // Pris maintenant ou jamais : à la première modification de la copie, on
      // ne saurait plus dire de quoi on est parti.
      server.subscription = subscription(source());

      final outcome = await service.follow(baseUrl, code: 'K7Q2M9XZ');

      final snapshot = await local.getUpstreamSnapshot(outcome.listId!);
      expect(snapshot, isNotNull);
      expect(snapshot!.sourceVersion, 7);
      expect(snapshot.entries.map((e) => e.id), [entryId, otherEntryId]);
    });

    test('rouvre la copie existante plutôt que d\'en empiler une seconde',
        () async {
      server.subscription = subscription(source());
      final first = await service.follow(baseUrl, code: 'K7Q2M9XZ');

      final second = await service.follow(baseUrl, code: 'K7Q2M9XZ');

      expect(second.status, FollowStatus.alreadyFollowing);
      expect(second.listId, first.listId);
      expect(await local.getAllSongLists(), hasLength(1));
    });

    test('ne duplique pas quand la copie a été faite sur un autre appareil',
        () async {
      // Elle arrivera par la synchro. En créer une ici laisserait
      // l'utilisateur avec deux copies de la même source.
      server.subscription = subscription(
        source(),
        existingCopyId: UuidValue.parse('55555555-5555-4555-8555-555555555555'),
      );

      final outcome = await service.follow(baseUrl, code: 'K7Q2M9XZ');

      expect(outcome.status, FollowStatus.alreadyFollowing);
      expect(outcome.listId, isNull);
      expect(await local.getAllSongLists(), isEmpty);
    });

    test('ouvre l\'originale quand le lien revient à son auteur', () async {
      server.subscription = subscription(source(), alreadyOwner: true);

      final outcome = await service.follow(baseUrl, code: 'K7Q2M9XZ');

      expect(outcome.status, FollowStatus.alreadyOwner);
      expect(outcome.listId, sourceId);
      expect(await local.getAllSongLists(), isEmpty);
    });

    test('laisse remonter un code qui ne mène à rien', () async {
      server.failure = const ShareLinkNotFoundException();

      expect(
        () => service.follow(baseUrl, code: 'INCONNU'),
        throwsA(isA<ShareLinkNotFoundException>()),
      );
    });
  });
}

final sourceId = UuidValue.parse('11111111-1111-4111-8111-111111111111');
final entryId = UuidValue.parse('22222222-2222-4222-8222-222222222222');
final otherEntryId = UuidValue.parse('44444444-4444-4444-8444-444444444444');
final songId = UuidValue.parse('33333333-3333-4333-8333-333333333333');

SongList source() {
  return SongList(
    id: sourceId,
    scheduledAt: DateTime(2026, 8, 2),
    createdAt: DateTime(2026, 7, 21),
    title: 'Dimanche',
    version: 7,
    entries: [
      SongListEntry(id: entryId, songId: songId, position: 0, savedSemitones: 2),
      SongListEntry(id: otherEntryId, songId: songId, position: 1),
    ],
  );
}

SubscriptionResult subscription(
  SongList source, {
  bool alreadyOwner = false,
  UuidValue? existingCopyId,
}) {
  return SubscriptionResult(
    source: source,
    alreadyOwner: alreadyOwner,
    existingCopyId: existingCopyId,
  );
}

/// Le serveur de quelqu'un d'autre : seul `subscribe` a besoin d'être piloté,
/// la synchro n'entre pas en jeu ici.
class _StubRemote implements RemoteSongListRepository {
  SubscriptionResult? subscription;
  Object? failure;

  @override
  Future<SubscriptionResult> subscribe(
    String baseUrl, {
    String? token,
    String? code,
  }) async {
    if (failure != null) throw failure!;
    return subscription!;
  }

  @override
  Future<ShareLink> share(String baseUrl, UuidValue id) =>
      throw UnimplementedError();

  @override
  Future<SongListSnapshot> fetchAll(String baseUrl) =>
      throw UnimplementedError();

  @override
  Future<SongList> fetchOne(String baseUrl, UuidValue id) =>
      throw UnimplementedError();

  @override
  Future<int> create(String baseUrl, SongList songList) =>
      throw UnimplementedError();

  @override
  Future<int> update(String baseUrl, SongList songList) =>
      throw UnimplementedError();

  @override
  Future<void> delete(String baseUrl, UuidValue id) =>
      throw UnimplementedError();
}
