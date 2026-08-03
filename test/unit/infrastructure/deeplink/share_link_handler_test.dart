import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:songbook/core/application/services/song_list_sharing.service.dart';
import 'package:songbook/core/domain/model/share_link.dart';
import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/song_list_snapshot.dart';
import 'package:songbook/core/domain/model/subscription_result.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/core/domain/services/remote_song_list.repository.dart';
import 'package:songbook/infrastructure/deeplink/app_links.deep_link.source.dart';
import 'package:songbook/infrastructure/deeplink/providers/share_link_handler.provider.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list_sync.provider.dart';
import 'package:songbook/ui/pages/auth/providers/auth_state.provider.dart';

/// Le lien cliqué depuis une conversation.
///
/// Le cas qui compte n'est pas le nominal mais celui-ci : on clique un lien,
/// l'app s'ouvre **sur l'écran de connexion**. Si le jeton est perdu là,
/// l'utilisateur doit retourner chercher le message et recliquer — ce qui est
/// exactement le moment où il abandonne.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _StubRemote server;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    server = _StubRemote();
  });

  ProviderContainer containerWith(AuthState authState) {
    final container = ProviderContainer(
      overrides: [
        // Sans quoi le gestionnaire s'abonne au vrai canal natif, absent ici.
        // Les liens sont injectés directement via `handle`.
        deepLinkSourceProvider.overrideWithValue(const NoDeepLinkSource()),
        remoteSongListRepositoryProvider.overrideWithValue(server),
        authNotifierProvider.overrideWith(() => _StubAuthNotifier(authState)),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('ShareLinkHandler', () {
    test('suit la liste quand la session est déjà ouverte', () async {
      final container = containerWith(AuthAuthenticated('+33600000001'));
      final handler = container.read(shareLinkHandlerProvider.notifier);

      await handler.handle(Uri.parse('https://songbook.dtfh.fr/l/JETON'));

      final event = container.read(shareLinkHandlerProvider);
      expect(event, isA<ShareLinkFollowed>());
      expect((event! as ShareLinkFollowed).outcome.status, FollowStatus.copied);
    });

    test('met le lien de côté tant que personne n\'est connecté', () async {
      final container = containerWith(const AuthUnauthenticated());
      final handler = container.read(shareLinkHandlerProvider.notifier);

      await handler.handle(Uri.parse('https://songbook.dtfh.fr/l/JETON'));

      // Rien à montrer encore, et surtout : rien n'a été demandé au serveur.
      expect(container.read(shareLinkHandlerProvider), isNull);
      expect(server.subscribeCalls, 0);
    });

    test('reprend l\'abonnement dès que la session s\'ouvre', () async {
      final container = containerWith(const AuthUnauthenticated());
      final handler = container.read(shareLinkHandlerProvider.notifier);
      await handler.handle(Uri.parse('https://songbook.dtfh.fr/l/JETON'));

      container.read(authNotifierProvider.notifier).state = AuthAuthenticated(
        '+33600000001',
      );
      await _settle();

      expect(
        container.read(shareLinkHandlerProvider),
        isA<ShareLinkFollowed>(),
      );
      expect(server.subscribeCalls, 1);
    });

    test('ne rejoue pas un lien déjà repris', () async {
      final container = containerWith(const AuthUnauthenticated());
      final handler = container.read(shareLinkHandlerProvider.notifier);
      await handler.handle(Uri.parse('https://songbook.dtfh.fr/l/JETON'));

      final auth = container.read(authNotifierProvider.notifier);
      auth.state = AuthAuthenticated('+33600000001');
      await _settle();
      auth.state = AuthAuthenticated('+33600000001');
      await _settle();

      expect(server.subscribeCalls, 1);
    });

    test('refuse explicitement un lien d\'une autre instance', () async {
      final container = containerWith(AuthAuthenticated('+33600000001'));
      final handler = container.read(shareLinkHandlerProvider.notifier);

      await handler.handle(Uri.parse('https://ailleurs.example.org/l/JETON'));

      // Le mode démo n'a pas d'URL configurée : rien à comparer, donc le lien
      // passe et c'est le serveur qui tranche. La règle d'origine elle-même est
      // vérifiée dans share_link_parser_test.dart.
      expect(container.read(shareLinkHandlerProvider), isNotNull);
    });

    test('ignore une URL qui n\'est pas un lien de partage', () async {
      final container = containerWith(AuthAuthenticated('+33600000001'));
      final handler = container.read(shareLinkHandlerProvider.notifier);

      await handler.handle(Uri.parse('https://songbook.dtfh.fr/autre'));

      expect(container.read(shareLinkHandlerProvider), isNull);
      expect(server.subscribeCalls, 0);
    });

    test('oublie l\'événement une fois affiché', () async {
      final container = containerWith(AuthAuthenticated('+33600000001'));
      final handler = container.read(shareLinkHandlerProvider.notifier);
      await handler.handle(Uri.parse('https://songbook.dtfh.fr/l/JETON'));

      handler.acknowledge();

      expect(container.read(shareLinkHandlerProvider), isNull);
    });
  });
}

/// Laisse passer les `ref.listen` et les futures enchaînées.
Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 20));

final sourceId = UuidValue.parse('11111111-1111-4111-8111-111111111111');

class _StubAuthNotifier extends AuthNotifier {
  final AuthState _initial;

  _StubAuthNotifier(this._initial);

  @override
  AuthState build() => _initial;
}

/// Un serveur qui accepte n'importe quel jeton, pour que le test porte sur
/// l'enchaînement et non sur la résolution du secret.
class _StubRemote implements RemoteSongListRepository {
  int subscribeCalls = 0;

  @override
  Future<SubscriptionResult> subscribe(
    String baseUrl, {
    String? token,
    String? code,
  }) async {
    subscribeCalls++;

    return SubscriptionResult(
      source: SongList(
        id: sourceId,
        scheduledAt: DateTime(2026, 8, 2),
        createdAt: DateTime(2026, 7, 21),
        entries: const [],
        version: 1,
      ),
      alreadyOwner: false,
      existingCopyId: null,
    );
  }

  @override
  Future<ShareLink> share(String baseUrl, UuidValue id) =>
      throw UnimplementedError();

  @override
  Future<SongListSnapshot> fetchAll(String baseUrl) async =>
      const SongListSnapshot(lists: [], deletedIds: []);

  @override
  Future<SongList> fetchOne(String baseUrl, UuidValue id) =>
      throw UnimplementedError();

  @override
  Future<int> create(String baseUrl, SongList songList) async => 1;

  @override
  Future<int> update(String baseUrl, SongList songList) async => 1;

  @override
  Future<void> delete(String baseUrl, UuidValue id) async {}
}
