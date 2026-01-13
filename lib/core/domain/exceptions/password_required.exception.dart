/// Exception levée quand une authentification par mot de passe est requise.
/// Cette exception est levée lorsque l'API retourne un code 401 (Unauthorized) ou 403 (Forbidden).
class PasswordRequiredException implements Exception {
  /// Message explicatif pour l'utilisateur
  final String message;

  /// Constructeur
  PasswordRequiredException([
    this.message =
        'Authentification requise. Veuillez saisir votre mot de passe.',
  ]);

  @override
  String toString() => 'PasswordRequiredException: $message';
}
