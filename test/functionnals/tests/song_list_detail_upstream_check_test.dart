import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/upstream_link.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
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

  Future<void> pumpDetail(WidgetTester tester, SongListDto dto) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          songsProvider.overrideWith((ref) async => []),
          songListsProvider.overrideWith((ref) async => [dto]),
          songListRepositoryProvider.overrideWithValue(local),
          remoteSongListRepositoryProvider.overrideWithValue(server),
          settingsRepositoryProvider.overrideWithValue(
            InMemorySettingsRepository(),
          ),
        ],
        child: MaterialApp(home: SongListDetailPage(songListId: listId.value)),
      ),
    );
    await tester.pumpAndSettle();
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
  sourceListId: sourceId.value,
  sourceVersion: 3,
);

SongListDto ordinaryDto() => SongListDto(
  id: listId.value,
  scheduledAt: DateTime(2026, 8, 2, 10),
  createdAt: DateTime(2026, 7, 21),
  entries: const [],
);
