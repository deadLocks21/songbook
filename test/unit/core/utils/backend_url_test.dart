import 'package:flutter_test/flutter_test.dart';
import 'package:songbook/core/utils/backend_url.dart';

void main() {
  group('BackendUrl.normalize', () {
    test('strips the path from a URL', () {
      expect(
        BackendUrl.normalize('https://songbook.dtfh.fr/api/songs/examples'),
        'https://songbook.dtfh.fr',
      );
    });

    test('drops query and fragment', () {
      expect(
        BackendUrl.normalize('https://songbook.dtfh.fr/a?b=1#c'),
        'https://songbook.dtfh.fr',
      );
    });

    test('removes a trailing slash', () {
      expect(
        BackendUrl.normalize('https://songbook.dtfh.fr/'),
        'https://songbook.dtfh.fr',
      );
    });

    test('trims surrounding whitespace', () {
      expect(
        BackendUrl.normalize('  https://songbook.dtfh.fr/x  '),
        'https://songbook.dtfh.fr',
      );
    });

    test('keeps a non-default port', () {
      expect(
        BackendUrl.normalize('http://localhost:8080/api'),
        'http://localhost:8080',
      );
    });

    test('is idempotent on an already-bare origin', () {
      expect(
        BackendUrl.normalize('https://songbook.dtfh.fr'),
        'https://songbook.dtfh.fr',
      );
    });

    test('returns the trimmed input unchanged when unparseable', () {
      expect(BackendUrl.normalize('  not a url  '), 'not a url');
    });

    test('keeps the "memory" sentinel unchanged', () {
      expect(BackendUrl.normalize('  memory  '), 'memory');
    });
  });

  group('BackendUrl.isInMemoryUrl', () {
    test('is true when null', () {
      expect(BackendUrl.isInMemoryUrl(null), isTrue);
    });

    test('is true when empty or blank', () {
      expect(BackendUrl.isInMemoryUrl(''), isTrue);
      expect(BackendUrl.isInMemoryUrl('   '), isTrue);
    });

    test('is true for the "memory" sentinel (trimmed)', () {
      expect(BackendUrl.isInMemoryUrl('memory'), isTrue);
      expect(BackendUrl.isInMemoryUrl('  memory  '), isTrue);
    });

    test('is false for a real URL', () {
      expect(BackendUrl.isInMemoryUrl('https://songbook.dtfh.fr'), isFalse);
    });
  });

  group('BackendUrl.validate', () {
    test('accepts a bare domain', () {
      expect(BackendUrl.validate('https://songbook.dtfh.fr'), isNull);
    });

    test('accepts a domain with a sole trailing slash', () {
      expect(BackendUrl.validate('https://songbook.dtfh.fr/'), isNull);
    });

    test('rejects an empty value', () {
      expect(BackendUrl.validate('  '), isNotNull);
    });

    test('rejects a missing scheme', () {
      expect(BackendUrl.validate('songbook.dtfh.fr'), isNotNull);
    });

    test('rejects a URL carrying a path', () {
      expect(
        BackendUrl.validate('https://songbook.dtfh.fr/api/songs'),
        isNotNull,
      );
    });

    test('rejects a query string', () {
      expect(BackendUrl.validate('https://songbook.dtfh.fr?x=1'), isNotNull);
    });

    test('accepts the "memory" sentinel', () {
      expect(BackendUrl.validate('memory'), isNull);
      expect(BackendUrl.validate('  memory  '), isNull);
    });
  });

  group('BackendUrl.join', () {
    test('joins origin and absolute path', () {
      expect(
        BackendUrl.join('https://songbook.dtfh.fr', '/api/songs'),
        'https://songbook.dtfh.fr/api/songs',
      );
    });

    test('collapses a double slash', () {
      expect(
        BackendUrl.join('https://songbook.dtfh.fr/', '/api/songs'),
        'https://songbook.dtfh.fr/api/songs',
      );
    });

    test('adds a missing leading slash on the path', () {
      expect(
        BackendUrl.join('https://songbook.dtfh.fr', 'api/songs'),
        'https://songbook.dtfh.fr/api/songs',
      );
    });
  });
}
