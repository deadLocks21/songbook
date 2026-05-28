import 'package:songbook/core/domain/model/auth_session.dart';

/// Contrat d'authentification par numéro de téléphone + code à usage unique (OTP).
///
/// Le flux est en deux temps, à la manière de Kidflix : on demande d'abord
/// l'envoi d'un OTP pour un numéro, puis on vérifie le code saisi, ce qui
/// renvoie une [AuthSession] (JWT). Le numéro est attendu au format E.164.
abstract interface class AuthRepository {
  /// Démarre l'authentification pour [phoneNumber] en (faisant) envoyer un OTP,
  /// auprès du serveur [baseUrl] (origine du backend).
  ///
  /// Lève une [AuthException] (message prêt à afficher) en cas d'échec.
  Future<void> requestOtp(String phoneNumber, String baseUrl);

  /// Vérifie le code [otp] reçu pour [phoneNumber] auprès de [baseUrl] et
  /// renvoie la session (JWT) en cas de succès.
  ///
  /// Lève une [AuthException] (message prêt à afficher) en cas d'échec.
  Future<AuthSession> verifyOtp(String phoneNumber, String otp, String baseUrl);
}
