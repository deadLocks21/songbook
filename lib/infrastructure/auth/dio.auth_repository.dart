import 'package:dio/dio.dart';
import 'package:songbook/core/domain/exceptions/auth.exception.dart';
import 'package:songbook/core/domain/model/auth_session.dart';
import 'package:songbook/core/domain/services/auth.repository.dart';
import 'package:songbook/core/utils/backend_endpoints.dart';
import 'package:songbook/core/utils/backend_url.dart';

/// Implémentation HTTP de [AuthRepository] suivant l'API (cf. API.md) :
/// `POST /api/auth/request-otp` puis `POST /api/auth/verify-otp`.
///
/// Les erreurs sont traduites en [AuthException] à message lisible, en se
/// basant sur le champ machine `code` de la réponse d'erreur unifiée
/// (`{ "error", "code" }`).
class DioAuthRepository implements AuthRepository {
  final Dio _dio;

  DioAuthRepository(this._dio);

  @override
  Future<void> requestOtp(String phoneNumber, String baseUrl) async {
    final url = BackendUrl.join(baseUrl, BackendEndpoints.requestOtp);
    try {
      await _dio.post<Map<String, dynamic>>(
        url,
        data: {'phone_number': phoneNumber},
      );
    } on DioException catch (e) {
      throw AuthException(_messageFor(e, _requestOtpMessages));
    }
  }

  @override
  Future<AuthSession> verifyOtp(
    String phoneNumber,
    String otp,
    String baseUrl,
  ) async {
    final url = BackendUrl.join(baseUrl, BackendEndpoints.verifyOtp);
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        data: {'phone_number': phoneNumber, 'code': otp},
      );
      final data = response.data;
      if (data == null || data['token'] is! String) {
        throw const AuthException('Réponse du serveur invalide.');
      }
      return AuthSession(
        token: data['token'] as String,
        expiresAt:
            DateTime.tryParse(data['expires_at'] as String? ?? '') ??
            DateTime.now().add(const Duration(days: 30)),
        phoneNumber: phoneNumber,
      );
    } on DioException catch (e) {
      throw AuthException(_messageFor(e, _verifyOtpMessages));
    }
  }

  /// Traduit une [DioException] en message FR, en privilégiant le `code`
  /// machine renvoyé par l'API, puis en distinguant l'erreur réseau du reste.
  String _messageFor(DioException e, Map<String, String> byCode) {
    final data = e.response?.data;
    final code = data is Map<String, dynamic> ? data['code'] as String? : null;
    if (code != null && byCode.containsKey(code)) {
      return byCode[code]!;
    }
    if (e.response == null) {
      return 'Connexion au serveur impossible. '
          'Vérifiez l\'URL du serveur et votre réseau.';
    }
    return 'Une erreur est survenue. Réessayez.';
  }

  static const Map<String, String> _requestOtpMessages = {
    'invalid_request': 'Requête invalide.',
    'invalid_phone_format': 'Numéro de téléphone invalide.',
    'unknown_phone_number': 'Numéro de téléphone inconnu.',
    'rate_limited': 'Trop de demandes. Réessayez dans quelques minutes.',
    'sms_failed': 'Envoi du SMS impossible. Réessayez.',
  };

  static const Map<String, String> _verifyOtpMessages = {
    'invalid_request': 'Requête invalide.',
    'invalid_phone_format': 'Numéro de téléphone invalide.',
    'invalid_otp': 'Code incorrect.',
    'otp_expired': 'Code expiré. Demandez un nouveau code.',
    'rate_limited': 'Trop de tentatives. Réessayez plus tard.',
  };
}
