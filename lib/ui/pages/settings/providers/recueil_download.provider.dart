import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/application/services/error_message.service.dart';
import 'package:songbook/core/application/usecases/cache_recueil_partitions.usecase.dart';
import 'package:songbook/infrastructure/settings/providers/settings.service_provider.dart';
import 'package:songbook/infrastructure/song/providers/sync.providers.dart';

/// État du téléchargement manuel des partitions des recueils sélectionnés.
sealed class RecueilDownloadState {
  const RecueilDownloadState();
}

/// Aucun téléchargement en cours.
class RecueilDownloadIdle extends RecueilDownloadState {
  const RecueilDownloadIdle();
}

/// Téléchargement en cours. [total] vaut 0 tant qu'il n'est pas connu.
class RecueilDownloadInProgress extends RecueilDownloadState {
  final int done;
  final int total;

  const RecueilDownloadInProgress(this.done, this.total);
}

/// Téléchargement terminé : [total] partitions traitées.
class RecueilDownloadSuccess extends RecueilDownloadState {
  final int total;

  const RecueilDownloadSuccess(this.total);
}

/// Échec du téléchargement (réseau, serveur, …).
class RecueilDownloadFailure extends RecueilDownloadState {
  final String message;

  const RecueilDownloadFailure(this.message);
}

/// Pilote le téléchargement, à la demande, des partitions des recueils cochés.
///
/// Contrairement au sync de la liste, ce flux ne touche pas à la base locale :
/// il récupère les chants filtrés (`/api/songs?recueils=...`) puis met en cache
/// toutes leurs partitions pour une consultation hors-ligne.
class RecueilDownloadNotifier extends Notifier<RecueilDownloadState> {
  @override
  RecueilDownloadState build() => const RecueilDownloadIdle();

  Future<void> download() async {
    final selected = await ref.read(selectedRecueilsProvider.future);
    if (selected.isEmpty) {
      state = const RecueilDownloadFailure('Aucun recueil sélectionné.');
      return;
    }

    state = const RecueilDownloadInProgress(0, 0);
    try {
      final baseUrl = await ref.read(backendUrlProvider.future);
      if (baseUrl == null || baseUrl.isEmpty) {
        state = const RecueilDownloadFailure('Aucun serveur configuré.');
        return;
      }

      final songs = await ref
          .read(remoteSongRepositoryProvider)
          .fetchSongs(baseUrl, recueils: selected);
      final cache = await ref.read(resourceCacheRepositoryProvider.future);

      var lastTotal = 0;
      await CacheRecueilPartitionsUseCase(cache).execute(
        songs,
        selected.toSet(),
        onProgress: (done, total) {
          lastTotal = total;
          state = RecueilDownloadInProgress(done, total);
        },
      );

      state = RecueilDownloadSuccess(lastTotal);
    } catch (e) {
      if (ErrorMessageService.isUnauthorized(e)) {
        // 401 invalid_token : la ré-authentification est gérée par
        // l'intercepteur Dio, on ne montre pas d'erreur réseau.
        state = const RecueilDownloadIdle();
        return;
      }
      state = RecueilDownloadFailure(
        ErrorMessageService.getNetworkErrorMessage(e),
      );
    }
  }
}

/// Provider pour le notifier de téléchargement des recueils.
final recueilDownloadNotifierProvider =
    NotifierProvider<RecueilDownloadNotifier, RecueilDownloadState>(
  RecueilDownloadNotifier.new,
);
