import 'package:songbook/core/domain/model/auth_session.dart';
import 'package:songbook/core/domain/services/auth_token_store.dart';

/// Stockage en mémoire de la session (web / tests) : non persisté entre deux
/// lancements de l'application.
class InMemoryAuthTokenStore implements AuthTokenStore {
  AuthSession? _session;

  @override
  Future<AuthSession?> read() async => _session;

  @override
  Future<void> write(AuthSession session) async => _session = session;

  @override
  Future<void> clear() async => _session = null;
}
