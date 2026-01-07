import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/domain/model/theme_mode.dart';
import 'package:songbook/infrastructure/theme/providers/theme.usecases_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeAsync = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                child: Center(child: Text('Erreur: $error')),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
