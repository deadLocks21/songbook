// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upstream_states.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Où en sont les sources suivies, d'après la dernière synchro.
///
/// Volontairement **en mémoire** : l'app se synchronise au démarrage, donc
/// conserver cet état d'une session à l'autre ne ferait que ressortir une
/// information périmée — un badge « mise à jour disponible » pour un tirage
/// déjà fait ailleurs.

@ProviderFor(UpstreamStates)
final upstreamStatesProvider = UpstreamStatesProvider._();

/// Où en sont les sources suivies, d'après la dernière synchro.
///
/// Volontairement **en mémoire** : l'app se synchronise au démarrage, donc
/// conserver cet état d'une session à l'autre ne ferait que ressortir une
/// information périmée — un badge « mise à jour disponible » pour un tirage
/// déjà fait ailleurs.
final class UpstreamStatesProvider
    extends $NotifierProvider<UpstreamStates, Map<UuidValue, UpstreamState>> {
  /// Où en sont les sources suivies, d'après la dernière synchro.
  ///
  /// Volontairement **en mémoire** : l'app se synchronise au démarrage, donc
  /// conserver cet état d'une session à l'autre ne ferait que ressortir une
  /// information périmée — un badge « mise à jour disponible » pour un tirage
  /// déjà fait ailleurs.
  UpstreamStatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'upstreamStatesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$upstreamStatesHash();

  @$internal
  @override
  UpstreamStates create() => UpstreamStates();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<UuidValue, UpstreamState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<UuidValue, UpstreamState>>(
        value,
      ),
    );
  }
}

String _$upstreamStatesHash() => r'b52cd45f5bc318e1b5d54b4ec5fd8841bc49644a';

/// Où en sont les sources suivies, d'après la dernière synchro.
///
/// Volontairement **en mémoire** : l'app se synchronise au démarrage, donc
/// conserver cet état d'une session à l'autre ne ferait que ressortir une
/// information périmée — un badge « mise à jour disponible » pour un tirage
/// déjà fait ailleurs.

abstract class _$UpstreamStates
    extends $Notifier<Map<UuidValue, UpstreamState>> {
  Map<UuidValue, UpstreamState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              Map<UuidValue, UpstreamState>,
              Map<UuidValue, UpstreamState>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<UuidValue, UpstreamState>,
                Map<UuidValue, UpstreamState>
              >,
              Map<UuidValue, UpstreamState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
