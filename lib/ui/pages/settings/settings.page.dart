import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/application/services/error_message.service.dart';
import 'package:songbook/core/domain/model/theme_mode.dart';
import 'package:songbook/infrastructure/theme/providers/theme.usecases_provider.dart';
import 'package:songbook/infrastructure/settings/providers/settings.usecases_provider.dart';
import 'package:songbook/infrastructure/song/providers/clear_database.provider.dart';
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
      if (!_isBackendUrlModified && _backendUrlController.text.isEmpty) {
        _backendUrlController.text = url ?? '';
        _originalBackendUrl = url ?? '';
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: Center(
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
                        const Text(
                          'URL du backend',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (!_isBackendUrlEditable)
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _isBackendUrlEditable = true;
                                _originalBackendUrl =
                                    _backendUrlController.text;
                                _isBackendUrlModified = false;
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
                                onPressed: () {
                                  setState(() {
                                    _backendUrlController.text =
                                        _originalBackendUrl;
                                    _isBackendUrlModified = false;
                                    _isBackendUrlEditable = false;
                                  });
                                },
                                icon: const Icon(Icons.close, size: 18),
                                label: const Text('Annuler'),
                              ),
                              TextButton.icon(
                                onPressed: _isBackendUrlModified
                                    ? () async {
                                        final url = _backendUrlController.text
                                            .trim();
                                        if (url.isNotEmpty) {
                                          // Le mot de passe est automatiquement supprimé par le use case
                                          await backendUrlNotifier
                                              .setBackendUrl(url);
                                          setState(() {
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
                      controller: _backendUrlController,
                      readOnly: !_isBackendUrlEditable,
                      decoration: InputDecoration(
                        hintText: 'https://api.example.com',
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
                                  icon: const Icon(Icons.sync),
                                  tooltip: 'Synchroniser',
                                  onPressed: () {
                                    final backendUrl = _backendUrlController
                                        .text
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
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Configurez l\'URL de votre serveur backend',
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
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
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
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
                            final clearDatabaseUseCase = await ref.read(
                              clearDatabaseUseCaseProvider.future,
                            );
                            await clearDatabaseUseCase.execute();

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
                          } catch (e) {
                            debugPrint('Error: $e');
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
      ),
    );
  }
}
