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

/// Provider pour le use case de récupération du mot de passe.

@ProviderFor(getPasswordUseCase)
final getPasswordUseCaseProvider = GetPasswordUseCaseProvider._();

/// Provider pour le use case de récupération du mot de passe.

final class GetPasswordUseCaseProvider
    extends
        $FunctionalProvider<
          GetPasswordUseCase,
          GetPasswordUseCase,
          GetPasswordUseCase
        >
    with $Provider<GetPasswordUseCase> {
  /// Provider pour le use case de récupération du mot de passe.
  GetPasswordUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getPasswordUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getPasswordUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetPasswordUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetPasswordUseCase create(Ref ref) {
    return getPasswordUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetPasswordUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetPasswordUseCase>(value),
    );
  }
}

String _$getPasswordUseCaseHash() =>
    r'e58c80aef81ae8efa488790f79a099b3b90181a9';

/// Provider pour le use case de stockage du mot de passe.

@ProviderFor(setPasswordUseCase)
final setPasswordUseCaseProvider = SetPasswordUseCaseProvider._();

/// Provider pour le use case de stockage du mot de passe.

final class SetPasswordUseCaseProvider
    extends
        $FunctionalProvider<
          SetPasswordUseCase,
          SetPasswordUseCase,
          SetPasswordUseCase
        >
    with $Provider<SetPasswordUseCase> {
  /// Provider pour le use case de stockage du mot de passe.
  SetPasswordUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setPasswordUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setPasswordUseCaseHash();

  @$internal
  @override
  $ProviderElement<SetPasswordUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SetPasswordUseCase create(Ref ref) {
    return setPasswordUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SetPasswordUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SetPasswordUseCase>(value),
    );
  }
}

String _$setPasswordUseCaseHash() =>
    r'b0bd59aabe170a9547afe74bef1ce52cc62c691e';

/// Provider pour le use case de récupération du répertoire de synchronisation.

@ProviderFor(getSyncDirectoryUseCase)
final getSyncDirectoryUseCaseProvider = GetSyncDirectoryUseCaseProvider._();

/// Provider pour le use case de récupération du répertoire de synchronisation.

final class GetSyncDirectoryUseCaseProvider
    extends
        $FunctionalProvider<
          GetSyncDirectoryUseCase,
          GetSyncDirectoryUseCase,
          GetSyncDirectoryUseCase
        >
    with $Provider<GetSyncDirectoryUseCase> {
  /// Provider pour le use case de récupération du répertoire de synchronisation.
  GetSyncDirectoryUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getSyncDirectoryUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getSyncDirectoryUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetSyncDirectoryUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetSyncDirectoryUseCase create(Ref ref) {
    return getSyncDirectoryUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetSyncDirectoryUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetSyncDirectoryUseCase>(value),
    );
  }
}

String _$getSyncDirectoryUseCaseHash() =>
    r'1e801104440a0b35f42a80ee057e03c9e288e18f';

/// Provider pour le use case de définition du répertoire de synchronisation.

@ProviderFor(setSyncDirectoryUseCase)
final setSyncDirectoryUseCaseProvider = SetSyncDirectoryUseCaseProvider._();

/// Provider pour le use case de définition du répertoire de synchronisation.

final class SetSyncDirectoryUseCaseProvider
    extends
        $FunctionalProvider<
          SetSyncDirectoryUseCase,
          SetSyncDirectoryUseCase,
          SetSyncDirectoryUseCase
        >
    with $Provider<SetSyncDirectoryUseCase> {
  /// Provider pour le use case de définition du répertoire de synchronisation.
  SetSyncDirectoryUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setSyncDirectoryUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setSyncDirectoryUseCaseHash();

  @$internal
  @override
  $ProviderElement<SetSyncDirectoryUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SetSyncDirectoryUseCase create(Ref ref) {
    return setSyncDirectoryUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SetSyncDirectoryUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SetSyncDirectoryUseCase>(value),
    );
  }
}

String _$setSyncDirectoryUseCaseHash() =>
    r'3c009311a0f3df0b80cff4bc8fc1cd67c0984332';

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

/// Notifier pour gérer l'état du répertoire de synchronisation

@ProviderFor(SyncDirectoryNotifier)
final syncDirectoryProvider = SyncDirectoryNotifierProvider._();

/// Notifier pour gérer l'état du répertoire de synchronisation
final class SyncDirectoryNotifierProvider
    extends $AsyncNotifierProvider<SyncDirectoryNotifier, String?> {
  /// Notifier pour gérer l'état du répertoire de synchronisation
  SyncDirectoryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncDirectoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncDirectoryNotifierHash();

  @$internal
  @override
  SyncDirectoryNotifier create() => SyncDirectoryNotifier();
}

String _$syncDirectoryNotifierHash() =>
    r'23ddfe3db7ee1d1ef5cb59c9d68e3e4f9d3c09b6';

/// Notifier pour gérer l'état du répertoire de synchronisation

abstract class _$SyncDirectoryNotifier extends $AsyncNotifier<String?> {
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
