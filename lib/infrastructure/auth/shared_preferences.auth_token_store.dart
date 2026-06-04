import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:songbook/core/domain/model/auth_session.dart';
import 'package:songbook/core/domain/services/auth_token_store.dart';

/// Persiste la session JWT dans `SharedPreferences`, comme les autres
/// paramètres de l'app. Le stockage n'est pas chiffré, mais il évite les
/// problèmes d'entitlement Keychain sur macOS et reste cloisonné par app.
///
/// Un cache mémoire évite de relire le stockage à chaque requête HTTP : la
/// valeur est lue une fois puis réutilisée jusqu'à la prochaine
/// écriture/effacement.
class SharedPreferencesAuthTokenStore implements AuthTokenStore {
  static const String _key = 'auth_session';

  SharedPreferences? _preferences;
  AuthSession? _cached;
  bool _loaded = false;

  Future<SharedPreferences> _ensureInitialized() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  @override
  Future<AuthSession?> read() async {
    if (_loaded) return _cached;
    try {
      final prefs = await _ensureInitialized();
      final raw = prefs.getString(_key);
      _cached = raw == null ? null : _decode(raw);
    } catch (_) {
      // Stockage indisponible : on dégrade en « pas de session ».
      _cached = null;
    }
    _loaded = true;
    return _cached;
  }

  @override
  Future<void> write(AuthSession session) async {
    _cached = session;
    _loaded = true;
    final prefs = await _ensureInitialized();
    await prefs.setString(_key, _encode(session));
  }

  @override
  Future<void> clear() async {
    _cached = null;
    _loaded = true;
    final prefs = await _ensureInitialized();
    await prefs.remove(_key);
  }

  String _encode(AuthSession s) => jsonEncode({
    'token': s.token,
    'expires_at': s.expiresAt.toIso8601String(),
    'phone_number': s.phoneNumber,
  });

  AuthSession _decode(String raw) {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return AuthSession(
      token: json['token'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      phoneNumber: json['phone_number'] as String? ?? '',
    );
  }
}
