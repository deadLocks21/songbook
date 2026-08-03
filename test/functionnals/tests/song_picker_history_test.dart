import 'package:flutter_test/flutter_test.dart';

import '../../builders/builders.dart';
import '../utils/index.dart';

/// Le sélecteur est l'endroit où se prend la décision de reprendre un chant ou
/// non : c'est là que l'historique doit être sous les yeux, sans aller le
/// chercher.
///
/// Les dates sont posées par rapport à maintenant, parce que c'est bien
/// l'horloge de l'appareil que l'écran interroge pour dire « il y a … ».
void main() {
  group('Sélecteur de chants - historique', () {
    testWidgets('dit depuis quand un chant n\'a pas été pris', (tester) async {
      final app = anApp()
          .withSongsList([
            aSong().withId('song-a').withCode('C001').withName('Chant A').build(),
          ])
          .withSongList(
            aSongList()
                .withId('passee')
                .withScheduledAt(
                  DateTime.now().subtract(const Duration(days: 21)),
                )
                .withSongEntry(songId: 'song-a')
                .build(),
          )
          .build();

      await (await startInSongListEditPage(
        tester,
        app: app,
        songList: aSongList().withId('en-cours').build(),
      )).tapAddSongFab().expectTextVisible('Chanté il y a 3 semaines').execute();
    });

    testWidgets('signale un chant déjà prévu dans une autre liste', (
      tester,
    ) async {
      final app = anApp()
          .withSongsList([
            aSong().withId('song-a').withCode('C001').withName('Chant A').build(),
          ])
          .withSongList(
            aSongList()
                .withId('a-venir')
                .withScheduledAt(DateTime.now().add(const Duration(days: 5)))
                .withSongEntry(songId: 'song-a')
                .build(),
          )
          .build();

      await (await startInSongListEditPage(
        tester,
        app: app,
        songList: aSongList().withId('en-cours').build(),
      )).tapAddSongFab().expectTextContaining('Déjà prévu').execute();
    });

    testWidgets('la liste en cours d\'édition ne se compte pas elle-même', (
      tester,
    ) async {
      // Le piège : la liste éditée est déjà enregistrée, donc elle figure parmi
      // les listes de l'appareil. Sans exclusion, chacun de ses chants
      // s'annoncerait « déjà prévu » — en pointant la liste sous les yeux de
      // l'utilisateur.
      final edited = aSongList()
          .withId('en-cours')
          .withScheduledAt(DateTime.now().add(const Duration(days: 5)))
          .withSongEntry(songId: 'song-a')
          .build();

      final app = anApp()
          .withSongsList([
            aSong().withId('song-a').withCode('C001').withName('Chant A').build(),
          ])
          .withSongList(edited)
          .build();

      await (await startInSongListEditPage(
        tester,
        app: app,
        songList: edited,
      )).tapAddSongFab().expectTextVisible('Jamais chanté').execute();
    });
  });
}
