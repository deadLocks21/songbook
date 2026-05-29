import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:songbook/core/application/dtos/song.dto.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/infrastructure/song/providers/song.service_provider.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list.service_provider.dart';
import 'package:songbook/ui/pages/sync/providers/sync_state.provider.dart';
import 'package:songbook/ui/pages/sync/sync.page.dart';

/// Régression : en mode démo (in-memory), une **2e** synchro (relogin, sync
/// manuelle…) doit quand même quitter l'écran de synchro.
///
/// `syncStateNotifierProvider` est global : son état reste `SyncSuccess` après
/// une 1re synchro. Une synchro in-memory étant quasi-instantanée, la
/// transition `SyncInProgress → SyncSuccess` était coalescée et un `ref.listen`
/// ne se déclenchait pas → l'écran « Mise à jour… » restait bloqué. Le
/// correctif pilote la navigation sur le `Future` attendu de `sync()`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SyncPage quitte l\'écran même si l\'état global est déjà '
      'SyncSuccess (boucle in-memory relogin / sync manuelle)', (tester) async {
    SharedPreferences.setMockInitialValues({}); // aucune URL → mode démo
    final container = ProviderContainer(
      overrides: [
        songsProvider.overrideWith((ref) async => <SongDto>[]),
        songListsProvider.overrideWith((ref) async => <SongListDto>[]),
      ],
    );
    addTearDown(container.dispose);

    // Pré-condition : une 1re synchro a déjà laissé l'état global à SyncSuccess.
    await container.read(syncStateNotifierProvider.notifier).sync('memory');
    expect(container.read(syncStateProvider), isA<SyncSuccess>());

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SyncPage(isStartupSync: true)),
      ),
    );

    // Laisse la 2e synchro + la navigation se faire (pumps bornés : un blocage
    // ferait échouer les assertions plutôt que pumpAndSettle qui timeout).
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    expect(
      find.textContaining('Mise à jour'),
      findsNothing,
      reason: 'ne doit pas rester bloqué sur l\'écran de synchro',
    );
    expect(find.text('Songbook'), findsOneWidget); // arrivé sur la HomePage
  });
}
