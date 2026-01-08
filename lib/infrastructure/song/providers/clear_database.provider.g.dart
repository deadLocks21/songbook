// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clear_database.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider pour le use case de vidage de la base de données

@ProviderFor(clearDatabaseUseCase)
final clearDatabaseUseCaseProvider = ClearDatabaseUseCaseProvider._();

/// Provider pour le use case de vidage de la base de données

final class ClearDatabaseUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<ClearDatabaseUseCase>,
          ClearDatabaseUseCase,
          FutureOr<ClearDatabaseUseCase>
        >
    with
        $FutureModifier<ClearDatabaseUseCase>,
        $FutureProvider<ClearDatabaseUseCase> {
  /// Provider pour le use case de vidage de la base de données
  ClearDatabaseUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clearDatabaseUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clearDatabaseUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<ClearDatabaseUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ClearDatabaseUseCase> create(Ref ref) {
    return clearDatabaseUseCase(ref);
  }
}

String _$clearDatabaseUseCaseHash() =>
    r'023e9d1d98f11ae418fe9b37b903329da58d94e3';
