import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/application/services/error_message.service.dart';
import 'package:songbook/core/domain/model/theme_mode.dart';
import 'package:songbook/infrastructure/logger/providers/logger.service_provider.dart';
import 'package:songbook/infrastructure/settings/providers/settings.service_provider.dart';
import 'package:songbook/infrastructure/song/providers/song.service_provider.dart';
import 'package:songbook/ui/pages/auth/auth_gate.dart';
import 'package:songbook/ui/pages/auth/providers/auth_state.provider.dart';
import 'package:songbook/ui/pages/sync/sync.page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  /// Ouvre l'écran de synchronisation manuelle (rafraîchit la liste des chants)
  /// et signale le résultat à l'utilisateur.
  Future<void> _runManualSync() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const SyncPage()),
    );
    if (!mounted || result != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Liste des chants synchronisée'),
        backgroundColor: Colors.green,
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final themeModeAsync = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);

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

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Base de données vidée avec succès',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e, stack) {
                          ref.read(loggerProvider).error(
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

            // Section Compte
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Compte',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                key: const Key('logoutButton'),
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Se déconnecter'),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
