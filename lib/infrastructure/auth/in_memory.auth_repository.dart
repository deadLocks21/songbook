import 'package:songbook/core/domain/exceptions/auth.exception.dart';
import 'package:songbook/core/domain/model/auth_session.dart';
import 'package:songbook/core/domain/services/auth.repository.dart';

/// Implémentation en mémoire de [AuthRepository] (web — où CORS empêche les
/// appels Dio directs — et dev sans backend).
///
/// Aucun appel réseau : un seul couple numéro/OTP est accepté et un faux JWT
/// est renvoyé. Le numéro attendu est au format E.164, comme après
/// normalisation côté service.
class InMemoryAuthRepository implements AuthRepository {
  static const String _acceptedPhoneNumber = '+33612345678';
  static const String _acceptedOtp = '000000';

  @override
  Future<void> requestOtp(String phoneNumber, String baseUrl) async {
    if (phoneNumber != _acceptedPhoneNumber) {
      throw const AuthException('Numéro de téléphone inconnu');
    }
  }

  @override
  Future<AuthSession> verifyOtp(
    String phoneNumber,
    String otp,
    String baseUrl,
  ) async {
    if (otp.trim() != _acceptedOtp) {
      throw const AuthException('Code incorrect');
    }
    return AuthSession(
      token: 'in-memory-token',
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      phoneNumber: phoneNumber,
    );
  }
}
