import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/ui/pages/chord_pro_viewer/key_label.dart';

void main() {
  group('transposedKeyLabel', () {
    test('renvoie la tonalité d\'origine pour 0 demi-ton', () {
      expect(transposedKeyLabel('C', 0), 'C');
    });

    test('transpose vers le haut', () {
      expect(transposedKeyLabel('C', 2), 'D');
      expect(transposedKeyLabel('G', 5), 'C');
    });

    test('transpose vers le bas', () {
      expect(transposedKeyLabel('A', -2), 'G');
    });

    test('renvoie null quand la tonalité d\'origine est inconnue', () {
      expect(transposedKeyLabel(null, 3), isNull);
    });
  });
}
