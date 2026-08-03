import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/core/domain/model/song_schedule.dart';

/// Ce qui sépare « déjà chanté » de « déjà prévu » est une comparaison à
/// maintenant — et les dates comparées ne viennent pas toutes du même endroit :
/// celles des listes créées ici sont locales, celles arrivées du serveur portent
/// une étiquette UTC. Les prendre pour des instants ferait dériver la frontière
/// avec le fuseau.
void main() {
  final now = DateTime(2026, 8, 3, 14, 0);

  group('SongSchedule.from', () {
    test('range les dates de part et d\'autre de maintenant', () {
      final schedule = SongSchedule.from([
        DateTime(2026, 7, 13, 10, 0),
        DateTime(2026, 8, 9, 10, 0),
        DateTime(2026, 6, 8, 10, 0),
      ], now: now);

      expect(schedule.past, [
        DateTime(2026, 7, 13, 10, 0),
        DateTime(2026, 6, 8, 10, 0),
      ]);
      expect(schedule.upcoming, [DateTime(2026, 8, 9, 10, 0)]);
    });

    test('retient la dernière fois chantée et la prochaine fois prévue', () {
      final schedule = SongSchedule.from([
        DateTime(2026, 6, 8, 10, 0),
        DateTime(2026, 7, 13, 10, 0),
        DateTime(2026, 8, 16, 10, 0),
        DateTime(2026, 8, 9, 10, 0),
      ], now: now);

      expect(schedule.lastSungAt, DateTime(2026, 7, 13, 10, 0));
      expect(schedule.nextPlannedAt, DateTime(2026, 8, 9, 10, 0));
    });

    test(
      'compare les dates telles qu\'elles s\'affichent, pas comme des instants',
      () {
        // Une liste du matin même, telle qu'elle revient du serveur : 10h00
        // étiquetées UTC. Prise pour un instant, elle serait encore à venir dans
        // tout fuseau à l'ouest de Greenwich, et déjà passée à l'est.
        final fromServer = DateTime.utc(2026, 8, 3, 10, 0);

        final schedule = SongSchedule.from([fromServer], now: now);

        expect(schedule.past, [DateTime(2026, 8, 3, 10, 0)]);
        expect(schedule.upcoming, isEmpty);
      },
    );

    test('ne compte qu\'une fois un chant repris deux fois le même jour', () {
      final schedule = SongSchedule.from([
        DateTime(2026, 7, 13, 10, 0),
        DateTime(2026, 7, 13, 10, 0),
      ], now: now);

      expect(schedule.past, hasLength(1));
    });

    test('compte les reprises des trois derniers mois', () {
      final schedule = SongSchedule.from([
        DateTime(2026, 7, 13, 10, 0),
        DateTime(2026, 6, 8, 10, 0),
        DateTime(2026, 5, 4, 10, 0),
        // Hors fenêtre : quatre mois plus tôt.
        DateTime(2026, 4, 6, 10, 0),
      ], now: now);

      expect(schedule.recentCount(now), 3);
    });

    test('garde dans la fenêtre le jour qui la commence', () {
      // Trois mois jour pour jour : le jour qui ouvre la fenêtre en fait
      // partie. Sinon un chant sortirait du compte pile ce matin-là, sans que
      // rien ne se soit passé entre-temps.
      final schedule = SongSchedule.from([
        DateTime(2026, 5, 3, 10, 0),
      ], now: now);

      expect(schedule.recentCount(now), 1);
    });

    test('ne compte pas ce qui est seulement prévu', () {
      // « Combien de fois pris » parle de ce qui a été chanté ; ce qui est à
      // venir se signale ailleurs, et n'a encore rien coûté au répertoire.
      final schedule = SongSchedule.from([
        DateTime(2026, 7, 13, 10, 0),
        DateTime(2026, 8, 9, 10, 0),
      ], now: now);

      expect(schedule.recentCount(now), 1);
    });

    test('un chant jamais programmé n\'a rien derrière ni devant lui', () {
      expect(SongSchedule.never.isEmpty, isTrue);
      expect(SongSchedule.never.lastSungAt, isNull);
      expect(SongSchedule.never.nextPlannedAt, isNull);
    });
  });
}
