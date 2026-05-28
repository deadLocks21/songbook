import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/application/services/auth.service.dart';
import 'package:songbook/infrastructure/auth/providers/auth.repository_provider.dart';
import 'package:songbook/infrastructure/auth/providers/auth_token_store.provider.dart';

part 'auth.service_provider.g.dart';

@riverpod
AuthService authService(Ref ref) {
  return AuthService(
    ref.watch(authRepositoryProvider),
    ref.watch(authTokenStoreProvider),
  );
}
