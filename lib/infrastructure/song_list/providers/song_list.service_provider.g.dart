// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_list.service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(setlistService)
final setlistServiceProvider = SetlistServiceProvider._();

final class SetlistServiceProvider
    extends $FunctionalProvider<SetlistService, SetlistService, SetlistService>
    with $Provider<SetlistService> {
  SetlistServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setlistServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setlistServiceHash();

  @$internal
  @override
  $ProviderElement<SetlistService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SetlistService create(Ref ref) {
    return setlistService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SetlistService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SetlistService>(value),
    );
  }
}

String _$setlistServiceHash() => r'cd133c2088d91537e8d30b3ba669dcd630471cad';

@ProviderFor(songLists)
final songListsProvider = SongListsProvider._();

final class SongListsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SongListDto>>,
          List<SongListDto>,
          FutureOr<List<SongListDto>>
        >
    with
        $FutureModifier<List<SongListDto>>,
        $FutureProvider<List<SongListDto>> {
  SongListsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'songListsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$songListsHash();

  @$internal
  @override
  $FutureProviderElement<List<SongListDto>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SongListDto>> create(Ref ref) {
    return songLists(ref);
  }
}

String _$songListsHash() => r'5e748aac4604ef6476a0f1eee58a64e2b256aebd';

/// L'historique de programmation de chaque chant, par identifiant de chant.
///
/// Dérivé des listes déjà chargées : rien de plus à lire en base, et tout ce qui
/// les fait bouger — un enregistrement, une synchro — rafraîchit l'historique
/// par la même occasion.
///
/// [excludingListId] est l'identifiant de la liste en cours d'édition, qui ne
/// doit pas se compter elle-même (cf. [SongScheduleService.bySongId]).

@ProviderFor(songSchedules)
final songSchedulesProvider = SongSchedulesFamily._();

/// L'historique de programmation de chaque chant, par identifiant de chant.
///
/// Dérivé des listes déjà chargées : rien de plus à lire en base, et tout ce qui
/// les fait bouger — un enregistrement, une synchro — rafraîchit l'historique
/// par la même occasion.
///
/// [excludingListId] est l'identifiant de la liste en cours d'édition, qui ne
/// doit pas se compter elle-même (cf. [SongScheduleService.bySongId]).

final class SongSchedulesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, SongSchedule>>,
          Map<String, SongSchedule>,
          FutureOr<Map<String, SongSchedule>>
        >
    with
        $FutureModifier<Map<String, SongSchedule>>,
        $FutureProvider<Map<String, SongSchedule>> {
  /// L'historique de programmation de chaque chant, par identifiant de chant.
  ///
  /// Dérivé des listes déjà chargées : rien de plus à lire en base, et tout ce qui
  /// les fait bouger — un enregistrement, une synchro — rafraîchit l'historique
  /// par la même occasion.
  ///
  /// [excludingListId] est l'identifiant de la liste en cours d'édition, qui ne
  /// doit pas se compter elle-même (cf. [SongScheduleService.bySongId]).
  SongSchedulesProvider._({
    required SongSchedulesFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'songSchedulesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$songSchedulesHash();

  @override
  String toString() {
    return r'songSchedulesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, SongSchedule>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, SongSchedule>> create(Ref ref) {
    final argument = this.argument as String?;
    return songSchedules(ref, excludingListId: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SongSchedulesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$songSchedulesHash() => r'c8058e9a4f58597454fc3b2a61794277a8ce2d42';

/// L'historique de programmation de chaque chant, par identifiant de chant.
///
/// Dérivé des listes déjà chargées : rien de plus à lire en base, et tout ce qui
/// les fait bouger — un enregistrement, une synchro — rafraîchit l'historique
/// par la même occasion.
///
/// [excludingListId] est l'identifiant de la liste en cours d'édition, qui ne
/// doit pas se compter elle-même (cf. [SongScheduleService.bySongId]).

final class SongSchedulesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Map<String, SongSchedule>>,
          String?
        > {
  SongSchedulesFamily._()
    : super(
        retry: null,
        name: r'songSchedulesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// L'historique de programmation de chaque chant, par identifiant de chant.
  ///
  /// Dérivé des listes déjà chargées : rien de plus à lire en base, et tout ce qui
  /// les fait bouger — un enregistrement, une synchro — rafraîchit l'historique
  /// par la même occasion.
  ///
  /// [excludingListId] est l'identifiant de la liste en cours d'édition, qui ne
  /// doit pas se compter elle-même (cf. [SongScheduleService.bySongId]).

  SongSchedulesProvider call({String? excludingListId}) =>
      SongSchedulesProvider._(argument: excludingListId, from: this);

  @override
  String toString() => r'songSchedulesProvider';
}
