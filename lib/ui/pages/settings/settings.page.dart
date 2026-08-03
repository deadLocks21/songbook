import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/application/services/error_message.service.dart';
import 'package:songbook/core/domain/model/display_resource_type.dart';
import 'package:songbook/core/domain/model/theme_mode.dart';
import 'package:songbook/core/domain/model/recueil.dart';
import 'package:songbook/infrastructure/logger/providers/logger.service_provider.dart';
import 'package:songbook/infrastructure/recueil/providers/recueil.providers.dart';
import 'package:songbook/infrastructure/settings/providers/settings.service_provider.dart';
import 'package:songbook/infrastructure/song/providers/song.service_provider.dart';
import 'package:songbook/ui/pages/auth/auth_gate.dart';
import 'package:songbook/ui/pages/auth/providers/auth_state.provider.dart';
import 'package:songbook/ui/pages/settings/providers/recueil_download.provider.dart';
import 'package:songbook/ui/pages/sync/sync.page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  /// Ouvre l'écran de synchronisation manuelle (rafraîchit la liste des chants).
  Future<void> _runManualSync() {
    return Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (context) => const SyncPage()));
  }

  /// Déconnecte l'utilisateur et revient à l'écran de connexion.
  ///
  /// La connexion ayant remplacé `AuthGate` par la home dans la pile de
  /// navigation, on renavigue explicitement vers un `AuthGate` neuf (qui
  /// affiche la saisie du numéro puisque l'état est repassé à non authentifié).
  Future<void> _logout() async {
    await ref.read(authNotifierProvider.notifier).logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const AuthGate()),
      (route) => false,
    );
  }

  /// Vrai s'il reste au moins un chant à télécharger parmi les recueils
  /// [selected]. Un recueil dont les statistiques ne sont pas encore connues est
  /// considéré comme « à télécharger » (on propose alors le bouton).
  bool _hasPendingDownload(
    List<String> selected,
    Map<String, RecueilSongStats> stats,
  ) {
    for (final code in selected) {
      final stat = stats[code];
      if (stat == null || stat.downloaded < stat.total) {
        return true;
      }
    }
    return false;
  }

  /// Sous-titre d'un recueil : code, total de chants et nombre déjà téléchargé.
  String _recueilSubtitle(
    Recueil recueil,
    Map<String, RecueilSongStats> stats,
  ) {
    final stat = stats[recueil.code];
    if (stat == null) {
      return recueil.code;
    }
    return '${recueil.code} · ${stat.downloaded}/${stat.total} téléchargé(s)';
  }

  /// Libellé affiché pour un type de ressource.
  String _displayResourceLabel(DisplayResourceType type) => switch (type) {
    DisplayResourceType.partition => 'Partition',
    DisplayResourceType.chordPro => 'Accords',
  };

  /// Icône associée à un type de ressource.
  IconData _displayResourceIcon(DisplayResourceType type) => switch (type) {
    DisplayResourceType.partition => Icons.music_note,
    DisplayResourceType.chordPro => Icons.lyrics,
  };

  /// Liste réordonnable définissant la priorité d'affichage des ressources.
  /// Le premier type disponible pour un chant est affiché par défaut.
  Widget _buildResourceDisplayOrderSection() {
    final orderAsync = ref.watch(resourceDisplayOrderProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Priorité d\'affichage',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            'Glissez pour ordonner. Le premier type disponible pour un chant '
            'est affiché par défaut ; l\'autre reste accessible dans le chant.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          orderAsync.when(
            data: (order) => ReorderableListView(
              key: const Key('resourceDisplayOrderList'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorder: (oldIndex, newIndex) => ref
                  .read(resourceDisplayOrderProvider.notifier)
                  .reorder(oldIndex, newIndex),
              children: [
                for (var i = 0; i < order.length; i++)
                  ListTile(
                    key: ValueKey(order[i]),
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(_displayResourceIcon(order[i])),
                    title: Text('${i + 1}. ${_displayResourceLabel(order[i])}'),
                    trailing: const Icon(Icons.drag_handle),
                  ),
              ],
            ),
            loading: () => const SizedBox(
              height: 60,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// Liste des recueils disponibles avec une case à cocher par recueil.
  ///
  /// Cocher un recueil ne modifie pas la liste des chants (toujours
  /// synchronisée intégralement) : il déclenche le téléchargement local de
  /// toutes ses partitions à la prochaine synchronisation.
  Widget _buildRecueilsSection() {
    final recueilsAsync = ref.watch(availableRecueilsProvider);
    final selectedAsync = ref.watch(selectedRecueilsProvider);
    final selected = selectedAsync.value ?? const <String>[];
    final songStats =
        ref.watch(recueilSongStatsProvider).value ??
        const <String, RecueilSongStats>{};

    // Le bouton reste toujours affiché ; il est désactivé quand il n'y a rien à
    // télécharger (aucune sélection, ou tout déjà en cache pour la sélection).
    final canDownload =
        selected.isNotEmpty && _hasPendingDownload(selected, songStats);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cochez les recueils à rendre disponibles hors-ligne, puis lancez '
            'le téléchargement de leurs partitions avec le bouton ci-dessous.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          recueilsAsync.when(
            data: (recueils) {
              if (recueils.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Aucun recueil disponible.'),
                );
              }
              return Column(
                children: [
                  for (final Recueil recueil in recueils)
                    CheckboxListTile(
                      key: Key('recueilCheckbox_${recueil.code}'),
                      contentPadding: EdgeInsets.zero,
                      title: Text(recueil.name),
                      subtitle: Text(_recueilSubtitle(recueil, songStats)),
                      value: selected.contains(recueil.code),
                      onChanged: (checked) {
                        ref
                            .read(selectedRecueilsProvider.notifier)
                            .toggle(recueil.code, selected: checked ?? false);
                      },
                    ),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Impossible de charger les recueils : '
                      '${ErrorMessageService.getNetworkErrorMessage(error)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref.invalidate(availableRecueilsProvider),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildDownloadButton(canDownload: canDownload),
        ],
      ),
    );
  }

  /// Bouton de téléchargement des partitions des recueils cochés, avec barre de
  /// progression pendant l'opération.
  Widget _buildDownloadButton({required bool canDownload}) {
    final downloadState = ref.watch(recueilDownloadNotifierProvider);
    final inProgress = downloadState is RecueilDownloadInProgress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          key: const Key('downloadRecueilsButton'),
          onPressed: (inProgress || !canDownload)
              ? null
              : () => ref
                    .read(recueilDownloadNotifierProvider.notifier)
                    .download(),
          icon: inProgress
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download),
          label: Text(
            inProgress
                ? 'Téléchargement en cours…'
                : 'Télécharger les recueils sélectionnés',
          ),
        ),
        if (inProgress) ...[
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: downloadState.total == 0
                ? null
                : downloadState.done / downloadState.total,
          ),
          const SizedBox(height: 4),
          Text(
            downloadState.total == 0
                ? 'Préparation…'
                : 'Chants : ${downloadState.done}/${downloadState.total}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeModeAsync = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);

    // Retour utilisateur (snackbar) à la fin du téléchargement des recueils.
    ref.listen<RecueilDownloadState>(recueilDownloadNotifierProvider, (
      previous,
      next,
    ) {
      if (next is RecueilDownloadSuccess) {
        // Rafraîchit les compteurs « X/N téléchargé(s) » après le download.
        ref.invalidate(recueilSongStatsProvider);
      } else if (next is RecueilDownloadFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Échec du téléchargement : ${next.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView(
          children: [
            // Titre section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Apparence',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),

            // Sélecteur de thème avec SegmentedButton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: themeModeAsync.when(
                data: (currentThemeMode) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thème',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<AppThemeMode>(
                      key: const Key('themeSegmentedButton'),
                      segments: const [
                        ButtonSegment<AppThemeMode>(
                          value: AppThemeMode.light,
                          label: Text('Clair'),
                          icon: Icon(Icons.light_mode),
                        ),
                        ButtonSegment<AppThemeMode>(
                          value: AppThemeMode.dark,
                          label: Text('Sombre'),
                          icon: Icon(Icons.dark_mode),
                        ),
                        ButtonSegment<AppThemeMode>(
                          value: AppThemeMode.system,
                          label: Text('Auto'),
                          icon: Icon(Icons.smartphone),
                        ),
                      ],
                      selected: {currentThemeMode},
                      onSelectionChanged: (Set<AppThemeMode> newSelection) {
                        final selectedMode = newSelection.first;
                        themeNotifier.setThemeMode(selectedMode);
                      },
                    ),
                  ],
                ),
                loading: () => const SizedBox(
                  height: 60,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => SizedBox(
                  height: 60,
                  child: Center(
                    child: Text(
                      'Erreur: ${ErrorMessageService.getNetworkErrorMessage(error)}',
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Priorité d'affichage des ressources (Partition / Accords)
            _buildResourceDisplayOrderSection(),

            const SizedBox(height: 32),

            // Section Gestion des données
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Gestion des données',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),

            // Synchronisation manuelle de la liste des chants. L'URL du serveur
            // se configure avant connexion (roue crantée de l'écran de
            // connexion) : on ne change pas de backend une fois connecté.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Liste des chants',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    key: const Key('manualSyncButton'),
                    onPressed: _runManualSync,
                    icon: const Icon(Icons.sync),
                    label: const Text('Synchroniser maintenant'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Récupère la dernière version des chants depuis le serveur '
                    'configuré.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Recueils à synchroniser
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Recueils à synchroniser',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 8),
            _buildRecueilsSection(),

            const SizedBox(height: 24),

            // Bouton pour vider la base de données
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Base de données',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    key: const Key('clearDatabaseButton'),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Vider la base de données'),
                          content: const Text(
                            'Êtes-vous sûr de vouloir supprimer tous les chants locaux ? '
                            'Cette action est irréversible.',
                          ),
                          actions: [
                            TextButton(
                              key: const Key('clearDatabaseCancelButton'),
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Annuler'),
                            ),
                            TextButton(
                              key: const Key('clearDatabaseConfirmButton'),
                              onPressed: () => Navigator.of(context).pop(true),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Supprimer'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true && context.mounted) {
                        try {
                          final service = await ref.read(
                            songCatalogServiceProvider.future,
                          );
                          await service.clearDatabase();

                          // Invalider le cache des chants pour forcer le rechargement
                          ref.invalidate(songsProvider);
                        } catch (e, stack) {
                          ref
                              .read(loggerProvider)
                              .error(
                                'database.clear_failed',
                                error: e,
                                stack: stack,
                              );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Erreur lors du vidage: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    label: const Text(
                      'Vider la base de données',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Supprime tous les chants stockés localement. Utilisez cette option si vous voulez recommencer avec une base vide.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Déconnexion (séparée du reste des réglages)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                key: const Key('logoutButton'),
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Se déconnecter',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
