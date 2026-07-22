import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:songbook/infrastructure/song_list/in_memory.remote_song_list.repository.dart';
import 'package:songbook/infrastructure/song_list/in_memory.song_list.repository.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list.repository_provider.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list_sync.provider.dart';

/// Régression : « Cannot use the Ref of songListSyncServiceProvider after it
/// has been disposed », au tirer-pour-rafraîchir de la liste.
///
/// Le service est **lu** (pas observé) par le notifier, et son provider est
/// auto-dispose : il disparaît donc aussitôt, pendant que la synchro qu'il
/// vient de lancer poursuit ses appels réseau. Tout ce que le service garde de
/// `ref` est mort au retour.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('la synchro aboutit alors que son provider a déjà été jeté', () async {
    final container = ProviderContainer(
      overrides: [
        songListRepositoryProvider.overrideWithValue(
          InMemorySongListRepository(),
        ),
        remoteSongListRepositoryProvider.overrideWithValue(
          InMemoryRemoteSongListRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    // Exactement ce que fait le notifier : une lecture ponctuelle, sans
    // abonnement qui maintiendrait le provider en vie.
    final service = await Future.value(
      container.read(songListSyncServiceProvider),
    );

    // Laisse l'auto-dispose faire son œuvre avant que la synchro ne rende la
    // main — c'est la fenêtre où le bug se produisait.
    await Future<void>.delayed(const Duration(milliseconds: 20));

    await expectLater(service.sync('https://songbook.test'), completes);
  });
}
