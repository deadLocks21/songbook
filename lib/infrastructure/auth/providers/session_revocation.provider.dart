import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_revocation.provider.g.dart';

/// Signal émis lorsqu'une route protégée renvoie `401 invalid_token` (JWT
/// absent, expiré ou invalide — cf. API.md).
///
/// C'est un simple compteur : chaque incrément = un événement de révocation
/// que l'UI observe pour purger l'état d'authentification et relancer le flux
/// OTP. Il sert de pont **sans cycle** entre l'intercepteur Dio
/// (infrastructure) et le notifier d'auth (UI), qui ne peuvent pas se
/// référencer directement.
@Riverpod(keepAlive: true)
class SessionRevocation extends _$SessionRevocation {
  @override
  int build() => 0;

  /// Signale une révocation de session (401 invalid_token).
  void signal() => state = state + 1;
}
