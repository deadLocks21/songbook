import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/domain/model/recueil.dart';
import 'package:songbook/core/domain/services/remote_recueil.repository.dart';
import 'package:songbook/infrastructure/recueil/dio.remote_recueil.repository.dart';
import 'package:songbook/infrastructure/recueil/in_memory.remote_recueil.repository.dart';
import 'package:songbook/infrastructure/settings/providers/settings.service_provider.dart';
import 'package:songbook/infrastructure/song/providers/sync.providers.dart';

part 'recueil.providers.g.dart';

/// Provider pour le repository des recueils distants.
/// Utilise l'implémentation en mémoire sur le web (CORS).
@riverpod
RemoteRecueilRepository remoteRecueilRepository(Ref ref) {
  if (kIsWeb) {
    return InMemoryRemoteRecueilRepository();
  }
  return DioRemoteRecueilRepository(ref.watch(dioProvider));
}

/// Liste des recueils disponibles sur le serveur configuré.
///
/// Nécessite l'authentification (JWT injecté par l'intercepteur Dio) : à
/// n'utiliser qu'après connexion.
@riverpod
Future<List<Recueil>> availableRecueils(Ref ref) async {
  final backendUrl = await ref.watch(backendUrlProvider.future);
  if (backendUrl == null || backendUrl.isEmpty) {
    return const [];
  }
  return ref.watch(remoteRecueilRepositoryProvider).fetchRecueils(backendUrl);
}

/// Nombre de chants par code de recueil, dérivé du champ `recueils` de chaque
/// chant renvoyé par `/api/songs`.
///
/// L'API `/api/recueils` ne fournit pas ce décompte ; on le calcule donc à
/// partir de la liste complète des chants (un seul appel réseau).
@riverpod
Future<Map<String, int>> recueilSongCounts(Ref ref) async {
  final backendUrl = await ref.watch(backendUrlProvider.future);
  if (backendUrl == null || backendUrl.isEmpty) {
    return const {};
  }
  final songs =
      await ref.watch(remoteSongRepositoryProvider).fetchSongs(backendUrl);
  final counts = <String, int>{};
  for (final song in songs) {
    for (final code in song.recueils) {
      counts[code] = (counts[code] ?? 0) + 1;
    }
  }
  return counts;
}
