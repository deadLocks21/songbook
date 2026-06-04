import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/domain/services/auth_token_store.dart';
import 'package:songbook/infrastructure/auth/in_memory.auth_token_store.dart';
import 'package:songbook/infrastructure/auth/shared_preferences.auth_token_store.dart';

part 'auth_token_store.provider.g.dart';

/// Stockage de la session : `SharedPreferences` hors web, en mémoire sur le
/// web (où le stockage persistant n'est pas souhaité).
///
/// `keepAlive` : une seule instance partagée par le service d'auth (écriture)
/// et l'intercepteur Dio (lecture du Bearer), pour que le cache reste cohérent.
@Riverpod(keepAlive: true)
AuthTokenStore authTokenStore(Ref ref) {
  if (kIsWeb) {
    return InMemoryAuthTokenStore();
  }
  return SharedPreferencesAuthTokenStore();
}
