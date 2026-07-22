import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/core/application/services/song_list_pull.service.dart';
import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/upstream_change.dart';
import 'package:songbook/core/domain/model/upstream_snapshot.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/infrastructure/song_list/in_memory.remote_song_list.repository.dart';
import 'package:songbook/infrastructure/song_list/in_memory.song_list.repository.dart';

/// Le tirage, vu de l'orchestration.
///
/// Deux comportements portent l'essentiel : une copie intacte se met à jour
/// **sans rien demander** — c'est le cas courant, et poser une question serait
/// faire arbitrer un conflit inexistant — et le repère avance **même quand
/// l'utilisateur écarte des changements**, sinon chaque tirage rappellerait les
/// mêmes refus.
void main() {
  const baseUrl = 'https://songbook.test';

  late InMemoryRemoteSongListRepository server;
  late InMemorySongListRepository local;
  late SongListPullService service;

  setUp(() {
    server = InMemoryRemoteSongListRepository();
    local = InMemorySongListRepository();
    service = SongListPullService(local, server);
  });

  /// Publie la source côté serveur et enregistre la copie locale qui la suit,
  /// avec l'instantané pris au moment de l'abonnement.
  Future<void> subscribe(List<UuidValue> songs, {bool withBaseline = true}) async {
    await server.create(baseUrl, sourceList(songs));
    final source = await server.fetchOne(baseUrl, sourceId);

    final copy = SongList.copyOf(source).copyWith(id: copyId);
    await local.addSongList(copy);
    if (withBaseline) {
      await local.saveUpstreamSnapshot(UpstreamSnapshot.of(copyId, source));
    }
  }

  /// L'auteur modifie sa liste.
  Future<void> authorSets(List<UuidValue> songs) async {
    final current = await server.fetchOne(baseUrl, sourceId);
    await server.update(baseUrl, sourceList(songs, version: current.version));
  }

  group('SongListPullService.pull', () {
    test('applique tout seul quand la copie n\'a pas été touchée', () async {
      await subscribe([alpha, beta]);
      await authorSets([alpha, beta, gamma]);

      final result = await service.pull(baseUrl, copyId);

      expect(result, isA<PulledAutomatically>());
      final copy = (await local.getSongListById(copyId))!;
      expect(copy.entries.map((e) => e.songId), [alpha, beta, gamma]);
    });

    test('fait avancer le repère après un tirage automatique', () async {
      await subscribe([alpha]);
      await authorSets([alpha, beta]);

      await service.pull(baseUrl, copyId);

      final copy = (await local.getSongListById(copyId))!;
      final source = await server.fetchOne(baseUrl, sourceId);
      expect(copy.upstream?.sourceVersion, source.version);
      // Rejouer ne propose plus rien.
      expect(await service.pull(baseUrl, copyId), isA<NothingToPull>());
    });

    test('demande un arbitrage quand la copie a été modifiée', () async {
      await subscribe([alpha, beta]);
      final mine = (await local.getSongListById(copyId))!;
      await local.updateSongList(
        mine.copyWith(entries: [mine.entries.first]), // j'ai retiré beta
      );
      await authorSets([alpha, beta, gamma]);

      final result = await service.pull(baseUrl, copyId);

      expect(result, isA<NeedsReview>());
      final diff = (result as NeedsReview).preview.diff;
      expect(diff.isApproximate, isFalse);
      // Le retrait de beta est le mien : l'auteur ne l'a pas fait, donc rien
      // n'est proposé à son sujet. Seul l'ajout de gamma remonte.
      expect(diff.changes.whereType<SongAddedUpstream>(), hasLength(1));
    });

    test('fait avancer le repère même quand on écarte des changements', () async {
      // Refuser, c'est décider : le changement écarté ne doit pas revenir
      // solliciter au tirage suivant.
      await subscribe([alpha]);
      final mine = (await local.getSongListById(copyId))!;
      await local.updateSongList(mine.copyWith(scheduledAt: DateTime(2027, 1, 1)));
      await authorSets([alpha, beta]);

      final review = await service.pull(baseUrl, copyId) as NeedsReview;
      await service.applyReviewed(review.preview, const {}); // rien retenu

      final copy = (await local.getSongListById(copyId))!;
      expect(copy.entries.map((e) => e.songId), [alpha]);
      expect(await service.pull(baseUrl, copyId), isA<NothingToPull>());
    });

    test('n\'applique que ce qui a été retenu', () async {
      await subscribe([alpha]);
      final mine = (await local.getSongListById(copyId))!;
      await local.updateSongList(mine.copyWith(scheduledAt: DateTime(2027, 1, 1)));
      await authorSets([alpha, beta]);

      final review = await service.pull(baseUrl, copyId) as NeedsReview;
      final added = review.preview.diff.changes
          .whereType<SongAddedUpstream>()
          .single;
      await service.applyReviewed(review.preview, {added.id});

      final copy = (await local.getSongListById(copyId))!;
      expect(copy.entries.map((e) => e.songId), [alpha, beta]);
      // La date, elle, reste la mienne.
      expect(copy.scheduledAt, DateTime(2027, 1, 1));
    });

    test('se déclare approximatif sans instantané de base', () async {
      // L'appareil qui a reçu la copie par synchro : il sait qu'il y a du
      // nouveau, mais ne peut pas distinguer ses modifications de celles de
      // l'auteur. L'écran doit le dire.
      await subscribe([alpha], withBaseline: false);
      final mine = (await local.getSongListById(copyId))!;
      await local.updateSongList(mine.copyWith(scheduledAt: DateTime(2027, 1, 1)));
      await authorSets([alpha, beta]);

      final result = await service.pull(baseUrl, copyId);

      expect((result as NeedsReview).preview.diff.isApproximate, isTrue);
    });

    test('signale une source disparue sans toucher à la copie', () async {
      await subscribe([alpha, beta]);
      await server.delete(baseUrl, sourceId);

      final result = await service.pull(baseUrl, copyId);

      expect(result, isA<UpstreamGone>());
      final copy = (await local.getSongListById(copyId))!;
      expect(copy.entries, hasLength(2));
      expect(copy.upstream, isNotNull);
    });

    test('ne propose rien sur une liste qui ne suit personne', () async {
      await local.addSongList(
        SongList(
          id: copyId,
          scheduledAt: DateTime(2026, 8, 2),
          createdAt: DateTime(2026, 7, 21),
          entries: const [],
        ),
      );

      expect(await service.pull(baseUrl, copyId), isA<NothingToPull>());
    });
  });

  group('SongListPullService.unfollow', () {
    test('coupe le lien amont et garde la copie', () async {
      await subscribe([alpha, beta]);

      await service.unfollow(copyId);

      final copy = (await local.getSongListById(copyId))!;
      expect(copy.upstream, isNull);
      expect(copy.isFollowing, isFalse);
      expect(copy.entries, hasLength(2));
    });
  });
}

final sourceId = UuidValue.parse('11111111-1111-4111-8111-111111111111');
final copyId = UuidValue.parse('22222222-2222-4222-8222-222222222222');
final alpha = UuidValue.parse('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa');
final beta = UuidValue.parse('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb');
final gamma = UuidValue.parse('cccccccc-cccc-4ccc-8ccc-cccccccccccc');

int _seed = 0;

SongList sourceList(List<UuidValue> songs, {int? version}) {
  return SongList(
    id: sourceId,
    scheduledAt: DateTime(2026, 8, 2, 10),
    createdAt: DateTime(2026, 7, 21),
    title: 'Dimanche',
    version: version,
    entries: [
      for (var i = 0; i < songs.length; i++)
        SongListEntry(
          id: UuidValue.parse(
            '00000000-0000-4000-8000-${(++_seed).toString().padLeft(12, '0')}',
          ),
          songId: songs[i],
          position: i,
        ),
    ],
  );
}
