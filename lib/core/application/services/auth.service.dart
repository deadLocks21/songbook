import 'package:songbook/core/domain/model/auth_session.dart';
import 'package:songbook/core/domain/services/auth.repository.dart';
import 'package:songbook/core/domain/services/auth_token_store.dart';
import 'package:songbook/core/utils/phone_number.dart';

/// Service applicatif d'authentification.
///
/// Orchestre le flux numéro → OTP → JWT : normalise le numéro en E.164, délègue
/// les appels au [AuthRepository], puis persiste/efface la session via le
/// [AuthTokenStore]. Les erreurs métier remontent sous forme d'`AuthException`.
class AuthService {
  final AuthRepository _authRepository;
  final AuthTokenStore _tokenStore;

  AuthService(this._authRepository, this._tokenStore);

  Future<void> requestOtp(String phoneNumber, String baseUrl) =>
      _authRepository.requestOtp(PhoneNumber.toE164(phoneNumber), baseUrl);

  Future<void> verifyOtp(String phoneNumber, String otp, String baseUrl) async {
    final session = await _authRepository.verifyOtp(
      PhoneNumber.toE164(phoneNumber),
      otp,
      baseUrl,
    );
    await _tokenStore.write(session);
  }

  /// Session courante si elle existe et n'est pas expirée, sinon `null`.
  Future<AuthSession?> currentSession() async {
    final session = await _tokenStore.read();
    if (session == null || session.isExpired) return null;
    return session;
  }

  /// Efface la session stockée (déconnexion).
  Future<void> logout() => _tokenStore.clear();
}
