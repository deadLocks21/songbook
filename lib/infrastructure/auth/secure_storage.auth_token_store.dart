import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:songbook/core/domain/model/auth_session.dart';
import 'package:songbook/core/domain/services/auth_token_store.dart';

/// Persiste la session JWT dans le keychain/keystore via
/// `flutter_secure_storage`, comme l'identifiant d'appareil.
///
/// Un cache mémoire évite de relire le keychain à chaque requête HTTP : la
/// valeur est lue une fois puis réutilisée jusqu'à la prochaine
/// écriture/effacement.
class SecureStorageAuthTokenStore implements AuthTokenStore {
  static const String _key = 'auth_session';

  final FlutterSecureStorage _storage;
  AuthSession? _cached;
  bool _loaded = false;

  SecureStorageAuthTokenStore([
    this._storage = const FlutterSecureStorage(
      mOptions: MacOsOptions(
        accessibility: KeychainAccessibility.first_unlock,
        synchronizable: false,
      ),
    ),
  ]);

  @override
  Future<AuthSession?> read() async {
    if (_loaded) return _cached;
    try {
      final raw = await _storage.read(key: _key);
      _cached = raw == null ? null : _decode(raw);
    } catch (_) {
      // Keychain indisponible : on dégrade en « pas de session ».
      _cached = null;
    }
    _loaded = true;
    return _cached;
  }

  @override
  Future<void> write(AuthSession session) async {
    _cached = session;
    _loaded = true;
    await _storage.write(key: _key, value: _encode(session));
  }

  @override
  Future<void> clear() async {
    _cached = null;
    _loaded = true;
    await _storage.delete(key: _key);
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
