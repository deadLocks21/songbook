import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/core/application/dtos/remote_song_list.dto.dart';
import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/upstream_link.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';

void main() {
  final listId = UuidValue.parse('11111111-1111-4111-8111-111111111111');
  final entryId = UuidValue.parse('22222222-2222-4222-8222-222222222222');
  final songId = UuidValue.parse('33333333-3333-4333-8333-333333333333');
  final sourceId = UuidValue.parse('55555555-5555-4555-8555-555555555555');

  SongList songList(DateTime scheduledAt) => SongList(
    id: listId,
    scheduledAt: scheduledAt,
    createdAt: DateTime(2026, 7, 21),
    entries: [
      SongListEntry(
        id: entryId,
        songId: songId,
        position: 0,
        savedSemitones: 2,
      ),
    ],
  );

  group('RemoteSongListDto', () {
    test('envoie l\'heure affichée, étiquetée en UTC', () {
      // Heure locale « au mur » : ce que l'utilisateur a choisi dans le picker.
      final payload = RemoteSongListDto.writePayload(
        songList(DateTime(2026, 8, 2, 10, 0)),
      );

      // Sans le « Z », le serveur interpréterait la date dans son propre fuseau.
      expect(payload['scheduledAt'], '2026-08-02T10:00:00.000Z');
    });

    test('rend la même heure après un aller-retour serveur', () {
      final sent = RemoteSongListDto.writePayload(
        songList(DateTime(2026, 8, 2, 10, 0)),
      );

      // Ce que renvoie l'API pour cette date (format `c` de PHP, serveur UTC).
      final returned = RemoteSongListDto.fromJson({
        'id': listId.value,
        'title': null,
        'scheduledAt': '2026-08-02T10:00:00+00:00',
        'version': 1,
        'createdAt': '2026-07-21T00:00:00+00:00',
        'entries': const [],
      }).toDomain();

      expect(sent['scheduledAt'], '2026-08-02T10:00:00.000Z');
      expect(returned.scheduledAt.hour, 10);
      expect(returned.scheduledAt.day, 2);
      // Renvoyer ce qui a été reçu ne dérive pas.
      expect(
        RemoteSongListDto.writePayload(returned)['scheduledAt'],
        sent['scheduledAt'],
      );
    });

    test('n\'annonce une version de base que pour une mise à jour', () {
      final list = songList(DateTime(2026, 8, 2, 10, 0));

      expect(
        RemoteSongListDto.writePayload(list).containsKey('baseVersion'),
        isFalse,
      );
      expect(
        RemoteSongListDto.writePayload(list, baseVersion: 3)['baseVersion'],
        3,
      );
    });

    test('transporte les entrées avec leur transposition', () {
      final payload = RemoteSongListDto.writePayload(
        songList(DateTime(2026, 8, 2, 10, 0)),
      );

      expect(payload['entries'], [
        {
          'id': entryId.value,
          'songId': songId.value,
          'position': 0,
          'savedSemitones': 2,
        },
      ]);
    });

    test('relit une liste renvoyée par l\'API', () {
      final list = RemoteSongListDto.fromJson({
        'id': listId.value,
        'title': 'Dimanche',
        'scheduledAt': '2026-08-02T10:00:00+00:00',
        'version': 4,
        'createdAt': '2026-07-21T12:00:00+00:00',
        'updatedAt': '2026-07-21T14:00:00+00:00',
        'entries': [
          {
            'id': entryId.value,
            'songId': songId.value,
            'position': 0,
            'savedSemitones': null,
          },
        ],
      }).toDomain();

      expect(list.id, listId);
      expect(list.title, 'Dimanche');
      expect(list.version, 4);
      expect(list.entries.single.songId, songId);
      expect(list.entries.single.savedSemitones, isNull);
    });

    test('relit le lien amont d\'une copie', () {
      final list = RemoteSongListDto.fromJson({
        'id': listId.value,
        'title': null,
        'scheduledAt': '2026-08-02T10:00:00+00:00',
        'version': 4,
        'createdAt': '2026-07-21T12:00:00+00:00',
        'sourceListId': sourceId.value,
        'sourceVersion': 7,
        'entries': const [],
      }).toDomain();

      expect(list.upstream?.sourceListId, sourceId);
      expect(list.upstream?.sourceVersion, 7);
      expect(list.isFollowing, isTrue);
    });

    test('n\'invente pas de lien amont sur une liste originale', () {
      final list = RemoteSongListDto.fromJson({
        'id': listId.value,
        'title': null,
        'scheduledAt': '2026-08-02T10:00:00+00:00',
        'version': 4,
        'createdAt': '2026-07-21T12:00:00+00:00',
        'sourceListId': null,
        'sourceVersion': null,
        'entries': const [],
      }).toDomain();

      expect(list.upstream, isNull);
      expect(list.isFollowing, isFalse);
    });

    test('renvoie le lien amont à chaque écriture', () {
      // Redonné et pas sous-entendu : c'est ce qui fait avancer le repère au
      // tirage. L'omettre couperait l'abonnement au premier enregistrement.
      final copy = songList(DateTime(2026, 8, 2)).copyWith(
        upstream: UpstreamLink(sourceListId: sourceId, sourceVersion: 7),
      );

      final payload = RemoteSongListDto.writePayload(copy, baseVersion: 3);

      expect(payload['sourceListId'], sourceId.value);
      expect(payload['sourceVersion'], 7);
    });

    test('envoie explicitement un lien amont vide pour une originale', () {
      // `null` explicite plutôt que champ absent : c'est ainsi qu'un
      // désabonnement se propage au serveur.
      final payload = RemoteSongListDto.writePayload(
        songList(DateTime(2026, 8, 2)),
      );

      expect(payload.containsKey('sourceListId'), isTrue);
      expect(payload['sourceListId'], isNull);
      expect(payload['sourceVersion'], isNull);
    });
  });
}
