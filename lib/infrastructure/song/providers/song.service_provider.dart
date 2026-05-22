import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/application/dtos/song.dto.dart';
import 'package:songbook/core/application/services/song_catalog.service.dart';
import 'package:songbook/infrastructure/logger/providers/logger.service_provider.dart';
import 'package:songbook/infrastructure/song/providers/song.repository_provider.dart';
import 'package:songbook/infrastructure/song/providers/sync.providers.dart';

part 'song.service_provider.g.dart';

@riverpod
Future<SongCatalogService> songCatalogService(Ref ref) async {
  final songRepository = ref.watch(songRepositoryProvider);
  final resourceRepository = await ref.watch(
    remoteResourceRepositoryProvider.future,
  );
  return SongCatalogService(songRepository, resourceRepository);
}

@riverpod
Future<List<SongDto>> songs(Ref ref) async {
  final logger = ref.read(loggerProvider);
  try {
    final service = await ref.watch(songCatalogServiceProvider.future);
    final result = await service.getAllSongs();
    logger.info('catalog.loaded', attrs: {'count': result.length});
    return result;
  } catch (e, stack) {
    logger.error('catalog.load_failed', error: e, stack: stack);
    rethrow;
  }
}
