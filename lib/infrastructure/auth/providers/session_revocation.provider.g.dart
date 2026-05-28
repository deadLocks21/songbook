// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_revocation.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Signal émis lorsqu'une route protégée renvoie `401 invalid_token` (JWT
/// absent, expiré ou invalide — cf. API.md).
///
/// C'est un simple compteur : chaque incrément = un événement de révocation
/// que l'UI observe pour purger l'état d'authentification et relancer le flux
/// OTP. Il sert de pont **sans cycle** entre l'intercepteur Dio
/// (infrastructure) et le notifier d'auth (UI), qui ne peuvent pas se
/// référencer directement.

@ProviderFor(SessionRevocation)
final sessionRevocationProvider = SessionRevocationProvider._();

/// Signal émis lorsqu'une route protégée renvoie `401 invalid_token` (JWT
/// absent, expiré ou invalide — cf. API.md).
///
/// C'est un simple compteur : chaque incrément = un événement de révocation
/// que l'UI observe pour purger l'état d'authentification et relancer le flux
/// OTP. Il sert de pont **sans cycle** entre l'intercepteur Dio
/// (infrastructure) et le notifier d'auth (UI), qui ne peuvent pas se
/// référencer directement.
final class SessionRevocationProvider
    extends $NotifierProvider<SessionRevocation, int> {
  /// Signal émis lorsqu'une route protégée renvoie `401 invalid_token` (JWT
  /// absent, expiré ou invalide — cf. API.md).
  ///
  /// C'est un simple compteur : chaque incrément = un événement de révocation
  /// que l'UI observe pour purger l'état d'authentification et relancer le flux
  /// OTP. Il sert de pont **sans cycle** entre l'intercepteur Dio
  /// (infrastructure) et le notifier d'auth (UI), qui ne peuvent pas se
  /// référencer directement.
  SessionRevocationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sessionRevocationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionRevocationHash();

  @$internal
  @override
  SessionRevocation create() => SessionRevocation();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$sessionRevocationHash() => r'08901b9e2a9e3990c278a34ef88923ca6fc3f37a';

/// Signal émis lorsqu'une route protégée renvoie `401 invalid_token` (JWT
/// absent, expiré ou invalide — cf. API.md).
///
/// C'est un simple compteur : chaque incrément = un événement de révocation
/// que l'UI observe pour purger l'état d'authentification et relancer le flux
/// OTP. Il sert de pont **sans cycle** entre l'intercepteur Dio
/// (infrastructure) et le notifier d'auth (UI), qui ne peuvent pas se
/// référencer directement.

abstract class _$SessionRevocation extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
