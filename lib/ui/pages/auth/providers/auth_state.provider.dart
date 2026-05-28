import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/application/services/auth.service.dart';
import 'package:songbook/core/application/services/logger_application.service.dart';
import 'package:songbook/core/domain/exceptions/auth.exception.dart';
import 'package:songbook/infrastructure/auth/providers/auth.service_provider.dart';
import 'package:songbook/infrastructure/logger/providers/logger.service_provider.dart';
import 'package:songbook/infrastructure/settings/providers/settings.service_provider.dart';

/// État du flux d'authentification : vérification initiale → saisie du numéro →
/// saisie de l'OTP → authentifié.
sealed class AuthState {
  const AuthState();
}

/// Vérification d'une éventuelle session persistée, au démarrage.
class AuthInitializing extends AuthState {
  const AuthInitializing();
}

/// Aucune authentification en cours : l'utilisateur saisit son numéro.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Un OTP a été demandé pour [phoneNumber] : l'utilisateur saisit le code.
class AuthOtpPending extends AuthState {
  final String phoneNumber;

  const AuthOtpPending(this.phoneNumber);
}

/// L'utilisateur est authentifié et peut accéder aux chants.
class AuthAuthenticated extends AuthState {
  final String phoneNumber;

  const AuthAuthenticated(this.phoneNumber);
}

/// Notifier du flux d'authentification.
///
/// Au démarrage il restaure une session JWT persistée (auto-login). C'est ce
/// notifier, et non les endpoints, qui conditionne l'accès aux chants (voir
/// `AuthGate`).
class AuthNotifier extends Notifier<AuthState> {
  AuthService get _authService => ref.read(authServiceProvider);

  LoggerApplicationService get _logger => ref.read(loggerProvider);

  @override
  AuthState build() {
    // Restaure une éventuelle session persistée avant d'afficher le login.
    _restore();
    return const AuthInitializing();
  }

  Future<void> _restore() async {
    try {
      final session = await _authService.currentSession();
      state = session != null
          ? AuthAuthenticated(session.phoneNumber)
          : const AuthUnauthenticated();
    } catch (e, stack) {
      _logger.warn('auth.restore_failed', error: e, stack: stack);
      state = const AuthUnauthenticated();
    }
  }

  /// URL du backend configurée, ou `null` si absente (rien à appeler).
  Future<String?> _backendUrl() async {
    final url = await ref.read(backendUrlProvider.future);
    return (url == null || url.isEmpty) ? null : url;
  }

  /// Demande l'envoi d'un OTP pour [phoneNumber].
  ///
  /// Retourne `null` en cas de succès (l'état passe à [AuthOtpPending]), sinon
  /// un message d'erreur à afficher.
  Future<String?> requestOtp(String phoneNumber) async {
    final baseUrl = await _backendUrl();
    if (baseUrl == null) {
      return 'Configurez d\'abord l\'URL du serveur (roue crantée).';
    }
    try {
      await _authService.requestOtp(phoneNumber, baseUrl);
      state = AuthOtpPending(phoneNumber);
      _logger.info('auth.otp_requested');
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e, stack) {
      _logger.error('auth.otp_request_failed', error: e, stack: stack);
      return 'Une erreur est survenue. Réessayez.';
    }
  }

  /// Vérifie l'[otp] pour le numéro en attente de validation.
  ///
  /// Retourne `null` en cas de succès (l'état passe à [AuthAuthenticated]),
  /// sinon un message d'erreur à afficher.
  Future<String?> verifyOtp(String otp) async {
    final current = state;
    if (current is! AuthOtpPending) {
      return 'Session expirée. Recommencez.';
    }
    final baseUrl = await _backendUrl();
    if (baseUrl == null) {
      return 'Configurez d\'abord l\'URL du serveur (roue crantée).';
    }
    try {
      await _authService.verifyOtp(current.phoneNumber, otp, baseUrl);
      state = AuthAuthenticated(current.phoneNumber);
      _logger.info('auth.authenticated');
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e, stack) {
      _logger.error('auth.otp_verify_failed', error: e, stack: stack);
      return 'Une erreur est survenue. Réessayez.';
    }
  }

  /// Revient à l'étape de saisie du numéro de téléphone.
  void backToPhoneEntry() => state = const AuthUnauthenticated();

  /// Déconnecte l'utilisateur : efface le token stocké, rebloque l'accès aux
  /// chants et repart de la saisie du numéro.
  Future<void> logout() async {
    state = const AuthUnauthenticated();
    try {
      await _authService.logout();
    } catch (e, stack) {
      _logger.warn('auth.logout_clear_failed', error: e, stack: stack);
    }
    _logger.info('auth.logged_out');
  }
}

/// Provider du notifier d'authentification.
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
