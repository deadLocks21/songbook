import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/core/application/services/share_link.parser.dart';

/// Ce que l'app fait des URL que le système lui remonte.
///
/// La règle qui compte est celle de l'origine : l'URL du backend est saisie par
/// l'utilisateur, donc rien ne garantit qu'un lien reçu vienne de l'instance
/// qu'on interroge. Le laisser passer produirait un « lien invalide » qui
/// accuse l'expéditeur alors que le problème est ailleurs.
void main() {
  const backend = 'https://songbook.dtfh.fr';

  group('ShareLinkParser', () {
    test('reconnaît un lien de partage de l\'instance configurée', () {
      final target = ShareLinkParser.parse(
        Uri.parse('https://songbook.dtfh.fr/l/M4KP7QRSTVWXYZ0123456789AB'),
        backendUrl: backend,
      );

      expect(target, isA<ShareLinkInvite>());
      expect((target as ShareLinkInvite).token, 'M4KP7QRSTVWXYZ0123456789AB');
    });

    test('signale un lien venu d\'une autre instance', () {
      final target = ShareLinkParser.parse(
        Uri.parse('https://autre.example.org/l/M4KP7QRSTVWXYZ0123456789AB'),
        backendUrl: backend,
      );

      expect(target, isA<ShareLinkForeignOrigin>());
      expect(
        (target as ShareLinkForeignOrigin).origin,
        'https://autre.example.org',
      );
    });

    test('distingue deux instances sur le même hôte', () {
      // Deux déploiements peuvent cohabiter derrière des ports différents ;
      // ne comparer que l'hôte les confondrait.
      final target = ShareLinkParser.parse(
        Uri.parse('https://songbook.dtfh.fr:8443/l/ABC'),
        backendUrl: backend,
      );

      expect(target, isA<ShareLinkForeignOrigin>());
    });

    test('ne confond pas http et https', () {
      final target = ShareLinkParser.parse(
        Uri.parse('http://songbook.dtfh.fr/l/ABC'),
        backendUrl: backend,
      );

      expect(target, isA<ShareLinkForeignOrigin>());
    });

    test('ignore la casse de l\'hôte', () {
      final target = ShareLinkParser.parse(
        Uri.parse('https://SongBook.DTFH.fr/l/ABC'),
        backendUrl: backend,
      );

      expect(target, isA<ShareLinkInvite>());
    });

    test('laisse passer quand aucun serveur n\'est configuré', () {
      // Il n'y a pas d'origine à comparer. La suite du flux dira que le jeton
      // ne mène à rien — ce qui est vrai, et plus juste que d'accuser
      // l'expéditeur.
      expect(
        ShareLinkParser.parse(Uri.parse('https://ailleurs.fr/l/ABC')),
        isA<ShareLinkInvite>(),
      );
      expect(
        ShareLinkParser.parse(
          Uri.parse('https://ailleurs.fr/l/ABC'),
          backendUrl: 'memory',
        ),
        isA<ShareLinkInvite>(),
      );
    });

    test('ignore une URL qui n\'est pas un lien de partage', () {
      for (final url in [
        'https://songbook.dtfh.fr/',
        'https://songbook.dtfh.fr/l',
        'https://songbook.dtfh.fr/l/ABC/DEF',
        'https://songbook.dtfh.fr/autre/ABC',
      ]) {
        expect(
          ShareLinkParser.parse(Uri.parse(url), backendUrl: backend),
          isA<ShareLinkIrrelevant>(),
          reason: '$url ne devrait pas être pris pour un lien de partage',
        );
      }
    });

    test('refuse un jeton aberrant sans passer par le serveur', () {
      final target = ShareLinkParser.parse(
        Uri.parse('https://songbook.dtfh.fr/l/${'A' * 200}'),
        backendUrl: backend,
      );

      expect(target, isA<ShareLinkIrrelevant>());
    });
  });
}
