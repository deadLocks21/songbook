import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:songbook/infrastructure/song/in_memory.song.repository.dart';
import 'package:songbook/infrastructure/song/providers/song.repository_provider.dart';
import 'package:songbook/infrastructure/song_list/in_memory.song_list.repository.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list.repository_provider.dart';

/// Régression : en mode démo (in-memory), les repos qui portent leur état en
/// instance doivent **survivre** à l'auto-dispose, sinon une nouvelle instance
/// vide est recréée entre la synchro et l'accueil → chants perdus (« count=0 »)
/// et re-synchros en boucle. Le correctif épingle l'instance via
/// `ref.keepAlive()` dans la branche in-memory.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({})); // aucune URL → démo

  test(
    'songRepository (in-memory) garde la même instance malgré l\'auto-dispose',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo1 = container.read(songRepositoryProvider);
      expect(repo1, isA<InMemorySongRepository>());

      // Laisse tourner un éventuel cycle d'auto-dispose (aucun listener attaché).
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final repo2 = container.read(songRepositoryProvider);
      expect(
        identical(repo1, repo2),
        isTrue,
        reason: 'keepAlive doit conserver la même instance (état des chants)',
      );
    },
  );

  test('songListRepository (in-memory) garde la même instance', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final repo1 = container.read(songListRepositoryProvider);
    expect(repo1, isA<InMemorySongListRepository>());

    await Future<void>.delayed(const Duration(milliseconds: 20));

    final repo2 = container.read(songListRepositoryProvider);
    expect(identical(repo1, repo2), isTrue);
  });
}
