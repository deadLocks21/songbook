import 'package:songbook/core/domain/model/auth_session.dart';

/// Stockage de la session d'authentification (JWT + expiration).
///
/// Persisté de façon sécurisée hors web ; en mémoire sur le web.
abstract interface class AuthTokenStore {
  /// Lit la session stockée, ou `null` si aucune.
  Future<AuthSession?> read();

  /// Persiste la session.
  Future<void> write(AuthSession session);

  /// Supprime la session stockée (déconnexion, token invalide).
  Future<void> clear();
}
