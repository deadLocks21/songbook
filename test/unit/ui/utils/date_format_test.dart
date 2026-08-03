import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/ui/utils/date_format.dart';

/// Le « il y a … » est ce sur quoi on s'appuie pour décider de reprendre un
/// chant ou non : il doit tomber juste aux frontières (une semaine, un mois) et
/// ne pas se décaler d'un jour au gré des changements d'heure.
void main() {
  // Un lundi, en début d'après-midi : de quoi vérifier que l'heure de la
  // journée ne compte pas dans le calcul.
  final now = DateTime(2026, 8, 3, 14, 30);

  group('formatRelativePast', () {
    test('dit « aujourd\'hui » pour le jour même, quelle que soit l\'heure', () {
      expect(formatRelativePast(DateTime(2026, 8, 3, 10, 0), now: now), "aujourd'hui");
    });

    test('dit « hier » pour la veille', () {
      expect(formatRelativePast(DateTime(2026, 8, 2, 10, 0), now: now), 'hier');
    });

    test('compte en jours dans la semaine', () {
      expect(
        formatRelativePast(DateTime(2026, 7, 31, 10, 0), now: now),
        'il y a 3 jours',
      );
    });

    test('bascule en semaines à sept jours', () {
      expect(
        formatRelativePast(DateTime(2026, 7, 27, 10, 0), now: now),
        'il y a une semaine',
      );
      expect(
        formatRelativePast(DateTime(2026, 7, 13, 10, 0), now: now),
        'il y a 3 semaines',
      );
    });

    test('bascule en mois au-delà de deux mois', () {
      expect(
        formatRelativePast(DateTime(2026, 6, 3, 10, 0), now: now),
        'il y a 2 mois',
      );
      expect(
        formatRelativePast(DateTime(2025, 10, 3, 10, 0), now: now),
        'il y a 10 mois',
      );
    });

    test('bascule en années au-delà de deux ans', () {
      expect(
        formatRelativePast(DateTime(2024, 2, 3, 10, 0), now: now),
        'il y a 2 ans',
      );
    });

    test('ne perd pas un jour au passage à l\'heure d\'été', () {
      // La nuit du 28 au 29 mars 2026 ne dure que 23 heures en Europe : compter
      // les heures écoulées ferait de ces deux jours un seul.
      expect(
        formatRelativePast(
          DateTime(2026, 3, 28, 10, 0),
          now: DateTime(2026, 3, 30, 10, 0),
        ),
        'il y a 2 jours',
      );
    });
  });

  group('formatShortDate', () {
    test('tait l\'année quand c\'est celle en cours', () {
      expect(formatShortDate(DateTime(2026, 8, 9, 10, 0), now: now), 'Dim 9 août');
    });

    test('donne l\'année quand elle diffère', () {
      expect(
        formatShortDate(DateTime(2025, 6, 15, 10, 0), now: now),
        'Dim 15 juin 2025',
      );
    });
  });
}
