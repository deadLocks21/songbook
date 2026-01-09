import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/infrastructure/theme/app_theme_data.dart';
import 'package:songbook/infrastructure/theme/providers/theme.usecases_provider.dart';
import 'package:songbook/ui/pages/sync/sync_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observer le mode de thème actuel
    final themeModeAsync = ref.watch(themeModeProvider);

    return themeModeAsync.when(
      data: (appThemeMode) => MaterialApp(
        title: 'Songbook',
        theme: AppThemeData.buildLightTheme(),
        darkTheme: AppThemeData.buildDarkTheme(),
        themeMode: AppThemeData.toFlutterThemeMode(appThemeMode),
        home: const SyncPage(isStartupSync: true),
      ),
      loading: () => MaterialApp(
        title: 'Songbook',
        theme: AppThemeData.buildLightTheme(),
        darkTheme: AppThemeData.buildDarkTheme(),
        themeMode:
            ThemeMode.system, // Utilise le thème système pendant le chargement
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (error, stack) => MaterialApp(
        title: 'Songbook',
        theme: AppThemeData.buildLightTheme(),
        darkTheme: AppThemeData.buildDarkTheme(),
        themeMode: ThemeMode.system, // Utilise le thème système en cas d'erreur
        home: Scaffold(
          body: Center(child: Text('Erreur de chargement du thème: $error')),
        ),
      ),
    );
  }
}
