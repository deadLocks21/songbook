// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_original_key.provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Résout la tonalité d'origine (`{key:}`) du fichier ChordPro d'un chant.
///
/// Télécharge/lit depuis le cache puis parse, exactement comme la visionneuse
/// ([CachedChordProViewer]). Renvoie `null` si le fichier ne déclare pas de
/// tonalité. Mis en cache par Riverpod : un chant déjà résolu n'est pas
/// re-téléchargé, et le cache disque évite le re-téléchargement entre sessions.

@ProviderFor(songOriginalKey)
final songOriginalKeyProvider = SongOriginalKeyFamily._();

/// Résout la tonalité d'origine (`{key:}`) du fichier ChordPro d'un chant.
///
/// Télécharge/lit depuis le cache puis parse, exactement comme la visionneuse
/// ([CachedChordProViewer]). Renvoie `null` si le fichier ne déclare pas de
/// tonalité. Mis en cache par Riverpod : un chant déjà résolu n'est pas
/// re-téléchargé, et le cache disque évite le re-téléchargement entre sessions.

final class SongOriginalKeyProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// Résout la tonalité d'origine (`{key:}`) du fichier ChordPro d'un chant.
  ///
  /// Télécharge/lit depuis le cache puis parse, exactement comme la visionneuse
  /// ([CachedChordProViewer]). Renvoie `null` si le fichier ne déclare pas de
  /// tonalité. Mis en cache par Riverpod : un chant déjà résolu n'est pas
  /// re-téléchargé, et le cache disque évite le re-téléchargement entre sessions.
  SongOriginalKeyProvider._({
    required SongOriginalKeyFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'songOriginalKeyProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$songOriginalKeyHash();

  @override
  String toString() {
    return r'songOriginalKeyProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as (String, String);
    return songOriginalKey(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is SongOriginalKeyProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$songOriginalKeyHash() => r'354bad058270fa6bb7ec3eee5b3e58c941cb3900';

/// Résout la tonalité d'origine (`{key:}`) du fichier ChordPro d'un chant.
///
/// Télécharge/lit depuis le cache puis parse, exactement comme la visionneuse
/// ([CachedChordProViewer]). Renvoie `null` si le fichier ne déclare pas de
/// tonalité. Mis en cache par Riverpod : un chant déjà résolu n'est pas
/// re-téléchargé, et le cache disque évite le re-téléchargement entre sessions.

final class SongOriginalKeyFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, (String, String)> {
  SongOriginalKeyFamily._()
    : super(
        retry: null,
        name: r'songOriginalKeyProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Résout la tonalité d'origine (`{key:}`) du fichier ChordPro d'un chant.
  ///
  /// Télécharge/lit depuis le cache puis parse, exactement comme la visionneuse
  /// ([CachedChordProViewer]). Renvoie `null` si le fichier ne déclare pas de
  /// tonalité. Mis en cache par Riverpod : un chant déjà résolu n'est pas
  /// re-téléchargé, et le cache disque évite le re-téléchargement entre sessions.

  SongOriginalKeyProvider call(String songId, String chordProUrl) =>
      SongOriginalKeyProvider._(argument: (songId, chordProUrl), from: this);

  @override
  String toString() => r'songOriginalKeyProvider';
}
