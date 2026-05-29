import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/domain/services/auth.repository.dart';
import 'package:songbook/infrastructure/auth/dio.auth_repository.dart';
import 'package:songbook/infrastructure/auth/in_memory.auth_repository.dart';
import 'package:songbook/infrastructure/settings/providers/in_memory_mode.provider.dart';
import 'package:songbook/infrastructure/song/providers/sync.providers.dart';

part 'auth.repository_provider.g.dart';

/// Fournit l'implémentation du repository d'authentification.
///
/// Vrais appels HTTP quand un backend réel est configuré ; en mémoire sinon
/// (web, aucune URL, ou URL « memory ») — cf. [inMemoryModeProvider].
@riverpod
AuthRepository authRepository(Ref ref) {
  if (ref.watch(inMemoryModeProvider)) {
    return InMemoryAuthRepository();
  }
  return DioAuthRepository(ref.watch(dioProvider));
}
