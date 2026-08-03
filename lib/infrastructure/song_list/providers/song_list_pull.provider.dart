import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:songbook/core/application/services/error_message.service.dart';
import 'package:songbook/core/application/services/song_list_pull.service.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';
import 'package:songbook/infrastructure/logger/providers/logger.service_provider.dart';
import 'package:songbook/infrastructure/settings/providers/settings.service_provider.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list.repository_provider.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list.service_provider.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list_sync.provider.dart';

part 'song_list_pull.provider.g.dart';

@riverpod
SongListPullService songListPullService(Ref ref) {
  return SongListPullService(
    ref.watch(songListRepositoryProvider),
    ref.watch(remoteSongListRepositoryProvider),
  );
}

/// Pilote le tirage depuis l'UI : résout l'URL du backend, appelle le service,
/// puis pousse et rafraîchit ce qui doit l'être.
///
/// L'état est `true` pendant un appel réseau.
@Riverpod(keepAlive: true)
class SongListPullNotifier extends _$SongListPullNotifier {
  @override
  bool build() => false;

  /// Va chercher ce qui a changé en amont, et applique tout seul si la copie
  /// n'a pas été touchée.
  Future<PullResult> pull(String copyId) async {
    return _run(
      (service, baseUrl) => service.pull(baseUrl, UuidValue.parse(copyId)),
      operation: 'song_list.pull',
    );
  }

  /// Applique les changements retenus après revue.
  Future<PullResult> applyReviewed(
    PullPreview preview,
    Set<String> selected,
  ) async {
    return _run((service, _) async {
      await service.applyReviewed(preview, selected);
      return PulledAutomatically(selected.length);
    }, operation: 'song_list.pull.apply');
  }

  /// Cesse de suivre la source. La copie reste, elle devient une liste
  /// ordinaire.
  Future<bool> unfollow(String copyId) async {
    final result = await _run((service, _) async {
      await service.unfollow(UuidValue.parse(copyId));
      return const NothingToPull();
    }, operation: 'song_list.unfollow');

    return result is! PullFailed;
  }

  Future<PullResult> _run(
    Future<PullResult> Function(SongListPullService service, String baseUrl)
    action, {
    required String operation,
  }) async {
    final logger = ref.read(loggerProvider);
    state = true;
    try {
      final baseUrl = await ref.read(backendUrlProvider.future) ?? '';
      final result = await action(
        ref.read(songListPullServiceProvider),
        baseUrl,
      );

      ref.invalidate(songListsProvider);

      // La copie vient de changer localement : elle doit rejoindre les autres
      // appareils sans attendre la prochaine synchro.
      if (result is PulledAutomatically) {
        await ref.read(songListSyncProvider.notifier).push();
      }

      return result;
    } catch (e, stack) {
      if (ErrorMessageService.isUnauthorized(e)) {
        logger.info('$operation.unauthorized');
        return const PullFailed();
      }
      logger.warn('$operation.failed', error: e, stack: stack);
      return const PullFailed();
    } finally {
      state = false;
    }
  }
}
