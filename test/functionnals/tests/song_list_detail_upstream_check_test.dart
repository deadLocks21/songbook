import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/core/domain/exceptions/song_list_sync.exception.dart';
import 'package:songbook/core/domain/model/share_link.dart';
import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/song_list_snapshot.dart';
import 'package:songbook/core/domain/model/subscription_result.dart';
import 'package:songbook/core/domain/model/upstream_link.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/remote_song_list.repository.dart';
import 'package:songbook/infrastructure/settings/in_memory.settings_repository.dart';
import 'package:songbook/infrastructure/settings/providers/settings.repository_provider.dart';
import 'package:songbook/infrastructure/song/providers/song.service_provider.dart';
import 'package:songbook/infrastructure/song_list/in_memory.remote_song_list.repository.dart';
import 'package:songbook/infrastructure/song_list/in_memory.song_list.repository.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list.repository_provider.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list.service_provider.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list_sync.provider.dart';
import 'package:songbook/ui/pages/song_list_detail/song_list_detail.page.dart';

/// Ouvrir une liste suivie va voir où en est sa source.
///
/// C'est le moment où ça sert : l'utilisateur regarde cette liste-là. Le faire
/// à la synchro générale interrogerait chaque source à chaque passage sans rien
/// apprendre de plus.
///
/// Le pendant compte autant : une liste ordinaire ne doit provoquer aucun
/// appel. Vérifier ce que personne ne suit serait du trafic pur.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late InMemorySongListRepository local;
  late InMemoryRemoteSongListRepository server;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    local = InMemorySongListRepository();
    server = InMemoryRemoteSongListRepository();
  });

  Future<void> pumpDetail(
    WidgetTester tester,
    SongListDto dto, {
    RemoteSongListRepository? remote,
    bool settle = true,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          songsProvider.overrideWith((ref) async => []),
          songListsProvider.overrideWith((ref) async => [dto]),
          songListRepositoryProvider.overrideWithValue(local),
          remoteSongListRepositoryProvider.overrideWithValue(remote ?? server),
          settingsRepositoryProvider.overrideWithValue(
            InMemorySettingsRepository(),
          ),
        ],
        child: MaterialApp(home: SongListDetailPage(songListId: listId.value)),
      ),
    );

    if (settle) {
      await tester.pumpAndSettle();
    } else {
      // Deux passes : la première construit l'écran, la seconde laisse partir
      // le post-frame callback qui lance la vérification.
      await tester.pump();
      await tester.pump();
    }
  }

  testWidgets('vérifie la source à l\'ouverture d\'une liste suivie', (
    tester,
  ) async {
    // Le serveur de démo ne connaît pas cette source : la vérification aboutit
    // donc à « la liste partagée n'existe plus », ce qui prouve qu'elle a bien
    // eu lieu — et que son issue est traitée, pas avalée.
    await local.addSongList(followedCopy());

    await pumpDetail(tester, followedDto());

    expect(
      find.textContaining('La liste partagée n\'existe plus'),
      findsOneWidget,
    );
  });

  testWidgets('coupe le lien amont quand la source a disparu', (tester) async {
    await local.addSongList(followedCopy());

    await pumpDetail(tester, followedDto());

    final copy = await local.getSongListById(listId);
    expect(copy!.isFollowing, isFalse);
    // La copie, elle, reste : elle appartient à son propriétaire.
    expect(copy.entries, isEmpty);
    expect(copy.scheduledAt, DateTime(2026, 8, 2, 10));
  });

  testWidgets('signale la vérification en cours, sans bloquer la liste', (
    tester,
  ) async {
    // Non bloquant : ce qui est affiché est la copie locale, utilisable telle
    // quelle. Geler l'écran ferait attendre pour une réponse qui, le plus
    // souvent, ne change rien — et rendrait l'app inutilisable hors ligne.
    final slow = _SlowRemote();
    await local.addSongList(followedCopy());

    await pumpDetail(tester, followedDto(), remote: slow, settle: false);

    expect(find.byKey(const Key('upstreamCheckIndicator')), findsOneWidget);
    // La page reste rendue et manipulable pendant ce temps — ici son état
    // vide, la liste de test n'ayant pas de chants.
    expect(find.byKey(const Key('songListDetailEmpty')), findsOneWidget);
    expect(find.byKey(const Key('editSongListButton')), findsOneWidget);

    slow.release();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('upstreamCheckIndicator')), findsNothing);
  });

  testWidgets('ne signale rien sur une liste ordinaire', (tester) async {
    final slow = _SlowRemote();
    await local.addSongList(
      SongList(
        id: listId,
        scheduledAt: DateTime(2026, 8, 2, 10),
        createdAt: DateTime(2026, 7, 21),
        entries: const [],
        version: 1,
      ),
    );

    await pumpDetail(tester, ordinaryDto(), remote: slow, settle: false);

    expect(find.byKey(const Key('upstreamCheckIndicator')), findsNothing);

    slow.release();
    await tester.pumpAndSettle();
  });

  testWidgets('ne propose pas de repartager une liste suivie', (tester) async {
    // Elle appartient à quelqu'un d'autre : la transmettre depuis ici sèmerait
    // la confusion sur qui en est l'auteur.
    await local.addSongList(followedCopy());

    await pumpDetail(tester, followedDto());

    expect(find.byKey(const Key('shareSongListButton')), findsNothing);
  });

  testWidgets('ne vérifie rien sur une liste ordinaire', (tester) async {
    await local.addSongList(
      SongList(
        id: listId,
        scheduledAt: DateTime(2026, 8, 2, 10),
        createdAt: DateTime(2026, 7, 21),
        entries: const [],
        version: 1,
      ),
    );

    await pumpDetail(tester, ordinaryDto());

    expect(find.byKey(const Key('songListPullMessage')), findsNothing);
  });
}

final listId = UuidValue.parse('11111111-1111-4111-8111-111111111111');
final sourceId = UuidValue.parse('22222222-2222-4222-8222-222222222222');

SongList followedCopy() => SongList(
  id: listId,
  scheduledAt: DateTime(2026, 8, 2, 10),
  createdAt: DateTime(2026, 7, 21),
  entries: const [],
  version: 1,
  upstream: UpstreamLink(sourceListId: sourceId, sourceVersion: 3),
);

SongListDto followedDto() => SongListDto(
  id: listId.value,
  scheduledAt: DateTime(2026, 8, 2, 10),
  createdAt: DateTime(2026, 7, 21),
  entries: const [],
  isFollowing: true,
);

SongListDto ordinaryDto() => SongListDto(
  id: listId.value,
  scheduledAt: DateTime(2026, 8, 2, 10),
  createdAt: DateTime(2026, 7, 21),
  entries: const [],
);

/// Une source qui ne répond pas avant qu'on le lui dise.
///
/// Sans elle, la vérification se résout en un tour de boucle et l'indicateur
/// n'existe le temps d'aucune frame : on ne testerait rien.
class _SlowRemote implements RemoteSongListRepository {
  final _held = Completer<void>();

  void release() => _held.complete();

  @override
  Future<SongList> fetchOne(String baseUrl, UuidValue id) async {
    await _held.future;
    throw const SongListGoneException();
  }

  @override
  Future<SongListSnapshot> fetchAll(String baseUrl) async =>
      const SongListSnapshot(lists: [], deletedIds: []);

  @override
  Future<ShareLink> share(String baseUrl, UuidValue id) =>
      throw UnimplementedError();

  @override
  Future<SubscriptionResult> subscribe(
    String baseUrl, {
    String? token,
    String? code,
  }) => throw UnimplementedError();

  @override
  Future<int> create(String baseUrl, SongList songList) async => 1;

  @override
  Future<int> update(String baseUrl, SongList songList) async => 1;

  @override
  Future<void> delete(String baseUrl, UuidValue id) async {}
}
