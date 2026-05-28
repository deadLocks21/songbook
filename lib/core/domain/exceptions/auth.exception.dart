/// Exception métier levée lorsqu'une étape d'authentification échoue
/// (numéro inconnu, code incorrect, …).
///
/// Le [message] est déjà rédigé en français pour être affiché à l'utilisateur.
class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
