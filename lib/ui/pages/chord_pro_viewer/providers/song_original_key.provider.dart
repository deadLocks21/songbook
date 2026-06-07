import 'dart:io';

import 'package:chord_pro/chord_pro.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/infrastructure/song/providers/sync.providers.dart';

part 'song_original_key.provider.g.dart';

/// Résout la tonalité d'origine (`{key:}`) du fichier ChordPro d'un chant.
///
/// Télécharge/lit depuis le cache puis parse, exactement comme la visionneuse
/// ([CachedChordProViewer]). Renvoie `null` si le fichier ne déclare pas de
/// tonalité. Mis en cache par Riverpod : un chant déjà résolu n'est pas
/// re-téléchargé, et le cache disque évite le re-téléchargement entre sessions.
@riverpod
Future<String?> songOriginalKey(
  Ref ref,
  String songId,
  String chordProUrl,
) async {
  final cache = await ref.watch(resourceCacheRepositoryProvider.future);
  final pathOrUrl = await cache.getCachedResource(
    chordProUrl,
    UuidValue.parse(songId),
  );

  final String source;
  // Sur le web (ou si le cache renvoie une URL), on récupère le texte via le
  // réseau ; sinon on lit le fichier mis en cache sur disque.
  if (kIsWeb ||
      pathOrUrl.startsWith('http://') ||
      pathOrUrl.startsWith('https://')) {
    final dio = ref.read(dioProvider);
    final response = await dio.get<String>(
      pathOrUrl,
      options: Options(responseType: ResponseType.plain),
    );
    source = response.data ?? '';
  } else {
    source = await File(pathOrUrl).readAsString();
  }

  return ChordPro.parseSong(source).metadata.key;
}
