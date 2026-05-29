// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'in_memory_mode.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(inMemoryMode)
final inMemoryModeProvider = InMemoryModeProvider._();

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

final class InMemoryModeProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
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
  InMemoryModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inMemoryModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inMemoryModeHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return inMemoryMode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$inMemoryModeHash() => r'047b6ccce110ac4a5eb2b721e1a4111116f4bf9d';
