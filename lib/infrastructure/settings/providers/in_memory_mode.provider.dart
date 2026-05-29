import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/utils/backend_url.dart';
import 'package:songbook/infrastructure/settings/providers/settings.service_provider.dart';

part 'in_memory_mode.provider.g.dart';

/// Vrai quand l'application doit utiliser ses implémentations en mémoire
/// (données factices, ni réseau ni disque) plutôt que les vraies.
///
/// Trois déclencheurs :
/// - le **web**, où CORS interdit les appels Dio directs et où le stockage
///   natif (keychain, sqflite) est indisponible ;
/// - l'**absence** d'URL backend configurée ;
/// - l'URL backend réglée sur la sentinelle [BackendUrl.memorySentinel]
///   (« memory ») — bascule de démo/dev explicite.
///
/// Tous les providers de repos qui distinguaient web/natif s'appuient dessus.
/// Volontairement **non** rattachés (sinon cycle, ou hors-sujet) : le repo de
/// réglages et le repo de thème — ils alimentent `settingsService` →
/// [backendUrlProvider], donc en dépendre boucle —, l'identité d'appareil et le
/// logger.
///
/// Lu sur la `value` courante de [backendUrlProvider] (préchargé dans `main`).
/// Stable en pratique en mode démo (URL vide ou « memory » → toujours `true`),
/// donc les repos ne rebasculent pas intempestivement ; les repos en mémoire
/// qui portent un état s'épinglent eux-mêmes (`ref.keepAlive`) pour survivre
/// aux cycles d'auto-dispose.
@riverpod
bool inMemoryMode(Ref ref) {
  if (kIsWeb) return true;
  final backendUrl = ref.watch(backendUrlProvider).value;
  return BackendUrl.isInMemoryUrl(backendUrl);
}
