/// Session d'authentification : le JWT obtenu après vérification de l'OTP, sa
/// date d'expiration et le numéro associé.
class AuthSession {
  final String token;
  final DateTime expiresAt;
  final String phoneNumber;

  const AuthSession({
    required this.token,
    required this.expiresAt,
    required this.phoneNumber,
  });

  /// Vrai si le token est expiré (avec une marge d'une minute pour éviter
  /// d'utiliser un token sur le point d'expirer).
  bool get isExpired =>
      DateTime.now().isAfter(expiresAt.subtract(const Duration(minutes: 1)));
}
