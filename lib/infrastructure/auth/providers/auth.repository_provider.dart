import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/domain/services/auth.repository.dart';
import 'package:songbook/infrastructure/auth/dio.auth_repository.dart';
import 'package:songbook/infrastructure/auth/in_memory.auth_repository.dart';
import 'package:songbook/infrastructure/song/providers/sync.providers.dart';

part 'auth.repository_provider.g.dart';

/// Fournit l'implémentation du repository d'authentification.
///
/// Vrais appels HTTP hors web ; en mémoire sur le web (CORS), comme pour le
/// repository des chants distants.
@riverpod
AuthRepository authRepository(Ref ref) {
  if (kIsWeb) {
    return InMemoryAuthRepository();
  }
  return DioAuthRepository(ref.watch(dioProvider));
}
