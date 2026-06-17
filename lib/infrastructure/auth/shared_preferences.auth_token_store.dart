import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:songbook/core/application/services/logger_application.service.dart';
import 'package:songbook/core/domain/model/auth_session.dart';
import 'package:songbook/core/domain/services/auth_token_store.dart';

/// Persiste la session JWT dans `SharedPreferences`, comme les autres
/// paramètres de l'app. Le stockage n'est pas chiffré, mais il évite les
/// problèmes d'entitlement Keychain sur macOS et reste cloisonné par app.
///
/// Un cache mémoire évite de relire le stockage à chaque requête HTTP : la
/// valeur est lue une fois puis réutilisée jusqu'à la prochaine
/// écriture/effacement.
///
/// Le [logger] (optionnel) sert à diagnostiquer les déconnexions silencieuses :
/// au démarrage on veut distinguer « clé absente » (jamais connecté, ou session
/// disparue du stockage sans `clear()` — typiquement un restore de backup) de
/// « clé présente mais illisible » (valeur corrompue). On ne journalise jamais
/// la valeur du token, seulement des métadonnées.
class SharedPreferencesAuthTokenStore implements AuthTokenStore {
  static const String _key = 'auth_session';

  final LoggerApplicationService? _logger;

  SharedPreferences? _preferences;
  AuthSession? _cached;
  bool _loaded = false;

  SharedPreferencesAuthTokenStore([this._logger]);

  Future<SharedPreferences> _ensureInitialized() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  @override
  Future<AuthSession?> read() async {
    if (_loaded) return _cached;

    SharedPreferences prefs;
    try {
      prefs = await _ensureInitialized();
    } catch (e, stack) {
      // Stockage indisponible : on dégrade en « pas de session ».
      _logger?.warn('auth.token.read_unavailable', error: e, stack: stack);
      _cached = null;
      _loaded = true;
      return _cached;
    }

    final raw = prefs.getString(_key);
    if (raw == null) {
      // Clé absente : soit jamais connecté, soit la session a disparu du
      // stockage (wipe / restore de backup) sans passer par `clear()`. Les
      // clés voisines présentes disent si c'est *tout* le fichier de prefs qui
      // a sauté ou seulement le token.
      _logger?.info(
        'auth.token.absent',
        attrs: {'prefs.keys': _presentKeys(prefs)},
      );
      _cached = null;
      _loaded = true;
      return _cached;
    }

    try {
      _cached = _decode(raw);
    } catch (e, stack) {
      // Valeur présente mais illisible. On ne journalise jamais `raw` (c'est le
      // JWT) — uniquement sa taille, pour distinguer un tronquage d'un format
      // inattendu.
      _logger?.warn(
        'auth.token.corrupt',
        attrs: {'prefs.keys': _presentKeys(prefs), 'raw.length': raw.length},
        error: e,
        stack: stack,
      );
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
    // Trace explicite que c'est *l'app* qui a retiré la session (logout ou 401),
    // par opposition à une disparition externe — où l'on verrait
    // `auth.token.absent` au prochain démarrage sans `auth.token.cleared` avant.
    _logger?.info('auth.token.cleared');
  }

  /// Noms (jamais les valeurs) des clés présentes, triés, pour distinguer
  /// « tout le fichier de prefs a sauté » de « seul le token a sauté ».
  String _presentKeys(SharedPreferences prefs) =>
      (prefs.getKeys().toList()..sort()).join(',');

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
