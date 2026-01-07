// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme.usecases_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider pour le usecase de récupération du thème

@ProviderFor(getThemeModeUseCase)
final getThemeModeUseCaseProvider = GetThemeModeUseCaseProvider._();

/// Provider pour le usecase de récupération du thème

final class GetThemeModeUseCaseProvider
    extends
        $FunctionalProvider<
          GetThemeModeUseCase,
          GetThemeModeUseCase,
          GetThemeModeUseCase
        >
    with $Provider<GetThemeModeUseCase> {
  /// Provider pour le usecase de récupération du thème
  GetThemeModeUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getThemeModeUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getThemeModeUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetThemeModeUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetThemeModeUseCase create(Ref ref) {
    return getThemeModeUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetThemeModeUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetThemeModeUseCase>(value),
    );
  }
}

String _$getThemeModeUseCaseHash() =>
    r'1f8347e068f37fb71ba2e88561ed12a6667d9c07';

/// Provider pour le usecase de définition du thème

@ProviderFor(setThemeModeUseCase)
final setThemeModeUseCaseProvider = SetThemeModeUseCaseProvider._();

/// Provider pour le usecase de définition du thème

final class SetThemeModeUseCaseProvider
    extends
        $FunctionalProvider<
          SetThemeModeUseCase,
          SetThemeModeUseCase,
          SetThemeModeUseCase
        >
    with $Provider<SetThemeModeUseCase> {
  /// Provider pour le usecase de définition du thème
  SetThemeModeUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setThemeModeUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setThemeModeUseCaseHash();

  @$internal
  @override
  $ProviderElement<SetThemeModeUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SetThemeModeUseCase create(Ref ref) {
    return setThemeModeUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SetThemeModeUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SetThemeModeUseCase>(value),
    );
  }
}

String _$setThemeModeUseCaseHash() =>
    r'3efc9c0bf3daf8afce4ea6b6a13a8f05587a09a6';

/// Notifier pour gérer l'état du thème avec la nouvelle API Riverpod

@ProviderFor(ThemeModeNotifier)
final themeModeProvider = ThemeModeNotifierProvider._();

/// Notifier pour gérer l'état du thème avec la nouvelle API Riverpod
final class ThemeModeNotifierProvider
    extends $AsyncNotifierProvider<ThemeModeNotifier, AppThemeMode> {
  /// Notifier pour gérer l'état du thème avec la nouvelle API Riverpod
  ThemeModeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeNotifierHash();

  @$internal
  @override
  ThemeModeNotifier create() => ThemeModeNotifier();
}

String _$themeModeNotifierHash() => r'656d96de0f56ec67d6edceca464785e100f64f38';

/// Notifier pour gérer l'état du thème avec la nouvelle API Riverpod

abstract class _$ThemeModeNotifier extends $AsyncNotifier<AppThemeMode> {
  FutureOr<AppThemeMode> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AppThemeMode>, AppThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppThemeMode>, AppThemeMode>,
              AsyncValue<AppThemeMode>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
