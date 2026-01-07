// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.usecases_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider pour le usecase de récupération de l'URL du backend

@ProviderFor(getBackendUrlUseCase)
final getBackendUrlUseCaseProvider = GetBackendUrlUseCaseProvider._();

/// Provider pour le usecase de récupération de l'URL du backend

final class GetBackendUrlUseCaseProvider
    extends
        $FunctionalProvider<
          GetBackendUrlUseCase,
          GetBackendUrlUseCase,
          GetBackendUrlUseCase
        >
    with $Provider<GetBackendUrlUseCase> {
  /// Provider pour le usecase de récupération de l'URL du backend
  GetBackendUrlUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getBackendUrlUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getBackendUrlUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetBackendUrlUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetBackendUrlUseCase create(Ref ref) {
    return getBackendUrlUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetBackendUrlUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetBackendUrlUseCase>(value),
    );
  }
}

String _$getBackendUrlUseCaseHash() =>
    r'e97962806380ee69913ff71641055555b83ff6f4';

/// Provider pour le usecase de définition de l'URL du backend

@ProviderFor(setBackendUrlUseCase)
final setBackendUrlUseCaseProvider = SetBackendUrlUseCaseProvider._();

/// Provider pour le usecase de définition de l'URL du backend

final class SetBackendUrlUseCaseProvider
    extends
        $FunctionalProvider<
          SetBackendUrlUseCase,
          SetBackendUrlUseCase,
          SetBackendUrlUseCase
        >
    with $Provider<SetBackendUrlUseCase> {
  /// Provider pour le usecase de définition de l'URL du backend
  SetBackendUrlUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setBackendUrlUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setBackendUrlUseCaseHash();

  @$internal
  @override
  $ProviderElement<SetBackendUrlUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SetBackendUrlUseCase create(Ref ref) {
    return setBackendUrlUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SetBackendUrlUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SetBackendUrlUseCase>(value),
    );
  }
}

String _$setBackendUrlUseCaseHash() =>
    r'779abaa90600b1a100d10f83004ce18eaf163776';

/// Notifier pour gérer l'état de l'URL du backend avec la nouvelle API Riverpod

@ProviderFor(BackendUrlNotifier)
final backendUrlProvider = BackendUrlNotifierProvider._();

/// Notifier pour gérer l'état de l'URL du backend avec la nouvelle API Riverpod
final class BackendUrlNotifierProvider
    extends $AsyncNotifierProvider<BackendUrlNotifier, String?> {
  /// Notifier pour gérer l'état de l'URL du backend avec la nouvelle API Riverpod
  BackendUrlNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backendUrlProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backendUrlNotifierHash();

  @$internal
  @override
  BackendUrlNotifier create() => BackendUrlNotifier();
}

String _$backendUrlNotifierHash() =>
    r'392aacb5708a60e9419b3a84217685518980b5ed';

/// Notifier pour gérer l'état de l'URL du backend avec la nouvelle API Riverpod

abstract class _$BackendUrlNotifier extends $AsyncNotifier<String?> {
  FutureOr<String?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
