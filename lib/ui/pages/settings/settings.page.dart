import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/application/services/error_message.service.dart';
import 'package:songbook/core/domain/model/theme_mode.dart';
import 'package:songbook/core/utils/backend_url.dart';
import 'package:songbook/infrastructure/logger/providers/logger.service_provider.dart';
import 'package:songbook/infrastructure/settings/providers/settings.service_provider.dart';
import 'package:songbook/infrastructure/song/providers/song.service_provider.dart';
import 'package:songbook/ui/pages/sync/sync.page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late TextEditingController _backendUrlController;
  bool _isBackendUrlModified = false;
  bool _isBackendUrlEditable = false;
  String _originalBackendUrl = '';
  String? _backendUrlError;

  @override
  void initState() {
    super.initState();
    _backendUrlController = TextEditingController();
  }

  @override
  void dispose() {
    _backendUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeModeAsync = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final backendUrlAsync = ref.watch(backendUrlProvider);
    final backendUrlNotifier = ref.read(backendUrlProvider.notifier);

    // Mettre à jour le contrôleur quand les données sont chargées
    backendUrlAsync.whenData((url) {
      if (!_isBackendUrlEditable) {
        _backendUrlController.text = url ?? '';
        _originalBackendUrl = url ?? '';
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

            const SizedBox(height: 32),

            // Section Backend
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Gestion des données',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),

            // URL du Backend
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: Text(
                          'URL du backend',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (!_isBackendUrlEditable)
                        TextButton.icon(
                          key: const Key('backendUrlEditButton'),
                          onPressed: () {
                            setState(() {
                              _isBackendUrlEditable = true;
                              _originalBackendUrl = _backendUrlController.text;
                              _isBackendUrlModified = false;
                              _backendUrlError = null;
                            });
                          },
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Modifier'),
                        )
                      else
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton.icon(
                              key: const Key('backendUrlCancelButton'),
                              onPressed: () {
                                setState(() {
                                  _backendUrlController.text =
                                      _originalBackendUrl;
                                  _isBackendUrlModified = false;
                                  _isBackendUrlEditable = false;
                                  _backendUrlError = null;
                                });
                              },
                              icon: const Icon(Icons.close, size: 18),
                              label: const Text('Annuler'),
                            ),
                            TextButton.icon(
                              key: const Key('backendUrlSaveButton'),
                              onPressed:
                                  (_isBackendUrlModified &&
                                      _backendUrlError == null)
                                  ? () async {
                                      final raw = _backendUrlController.text
                                          .trim();
                                      if (BackendUrl.validate(raw) == null) {
                                        // L'URL stockée est l'origine seule ;
                                        // les chemins d'API sont ajoutés dans
                                        // le code. Le mot de passe est
                                        // automatiquement supprimé par le use case.
                                        final url = BackendUrl.normalize(raw);
                                        await backendUrlNotifier.setBackendUrl(
                                          url,
                                        );
                                        setState(() {
                                          _backendUrlController.text = url;
                                          _isBackendUrlModified = false;
                                          _isBackendUrlEditable = false;
                                          _originalBackendUrl = url;
                                        });
                                        if (context.mounted) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const SyncPage(), // isStartupSync = false par défaut
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  : null,
                              icon: const Icon(Icons.save, size: 18),
                              label: const Text('Sauvegarder'),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    key: const Key('backendUrlField'),
                    controller: _backendUrlController,
                    readOnly: !_isBackendUrlEditable,
                    decoration: InputDecoration(
                      hintText: 'https://songbook.dtfh.fr',
                      errorText: _isBackendUrlEditable
                          ? _backendUrlError
                          : null,
                      border: const OutlineInputBorder(),
                      filled: !_isBackendUrlEditable,
                      fillColor: !_isBackendUrlEditable
                          ? Theme.of(
                              context,
                            ).disabledColor.withValues(alpha: 0.05)
                          : null,
                      suffixIcon: !_isBackendUrlEditable
                          ? Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: IconButton(
                                key: const Key('backendUrlSyncButton'),
                                icon: const Icon(Icons.sync),
                                tooltip: 'Synchroniser',
                                onPressed: () {
                                  final backendUrl = _backendUrlController.text
                                      .trim();
                                  if (backendUrl.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const SyncPage(), // isStartupSync = false par défaut
                                      ),
                                    );
                                  }
                                },
                              ),
                            )
                          : null,
                    ),
                    keyboardType: TextInputType.url,
                    onChanged: (value) {
                      setState(() {
                        _isBackendUrlModified = true;
                        _backendUrlError = BackendUrl.validate(value.trim());
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Saisissez uniquement le domaine de votre serveur '
                    '(ex : https://songbook.dtfh.fr), sans chemin',
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
          ],
        ),
      ),
    );
  }
}
