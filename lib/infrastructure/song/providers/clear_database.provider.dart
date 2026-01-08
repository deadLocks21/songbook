import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/application/usecases/clear_database.usecase.dart';
import 'package:songbook/infrastructure/song/providers/song.repository_provider.dart';
import 'package:songbook/infrastructure/song/providers/sync.providers.dart';

part 'clear_database.provider.g.dart';

/// Provider pour le use case de vidage de la base de données
@riverpod
Future<ClearDatabaseUseCase> clearDatabaseUseCase(Ref ref) async {
  final songRepository = ref.watch(songRepositoryProvider);
  final resourceRepository = await ref.watch(
    remoteResourceRepositoryProvider.future,
  );
  return ClearDatabaseUseCase(songRepository, resourceRepository);
}
