import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/application/services/logger_application.service.dart';
import 'package:songbook/infrastructure/device/providers/device_identity.service_provider.dart';
import 'package:songbook/infrastructure/logger/providers/logger.service_provider.dart';
import 'package:songbook/infrastructure/migrations/providers/migration_runner.provider.dart';
import 'package:songbook/infrastructure/theme/app_theme_data.dart';
import 'package:songbook/infrastructure/auth/providers/session_revocation.provider.dart';
import 'package:songbook/infrastructure/settings/providers/settings.service_provider.dart';
import 'package:songbook/ui/pages/auth/auth_gate.dart';
import 'package:songbook/ui/pages/auth/providers/auth_state.provider.dart';
import 'package:songbook/updating_splash.dart';

Future<void> main(List<String> args) async {
  // Mode « fenêtre de mise à jour » : l'updater desktop (tool/updater) lance
  // `songbook --updating …` pour afficher une petite fenêtre (prompt +
  // progression) pendant qu'il télécharge/installe la nouvelle version. On NE
  // démarre PAS l'app complète dans ce cas — le splash gère lui-même
  // `ensureInitialized` + `runApp`. Doit rester AVANT toute init lourde
  // (container Riverpod, migrations, préchargement du backend…).
  if (args.contains('--updating')) {
    runUpdatingSplash(args);
    return;
  }

  WidgetsFlutterBinding.ensureInitialized();

  // Build the Riverpod container manually so we can read the logger
  // before `runApp` and wire the framework-wide error handlers below.
  final container = ProviderContainer();
  final logger = container.read(loggerProvider);

  _installErrorHandlers(logger);

  // Resolve the persistent device id and stamp it onto the log context so
  // every subsequent record is attributable to this install. Best-effort:
  // a storage failure must not block startup.
  try {
    final deviceId = await container
        .read(deviceIdentityServiceProvider)
        .getDeviceId();
    container.read(logContextProvider).deviceId = deviceId;
  } catch (_) {
    // getDeviceId already degrades gracefully; ignore here too.
  }

  // Preload the backend URL so the real-vs-in-memory decision
  // (inMemoryModeProvider) is settled before the first repository read. Without
  // it, a transient in-memory start could miss restoring a persisted session
  // (the keepAlive token store). Best-effort: the notifier swallows its own
  // errors and resolves to null.
  await container.read(backendUrlProvider.future);

  // Run pending data migrations before the first screen reads the DB.
  // Web uses an in-memory repository (no sqflite), so there's nothing to
  // migrate there. The runner is log-and-continue and never throws, but we
  // guard defensively so a migration subsystem fault can't block startup.
  if (!kIsWeb) {
    try {
      await container.read(migrationRunnerProvider).run();
    } catch (e, stack) {
      logger.error('migration.runner_failed', error: e, stack: stack);
    }
  }

  logger.info('app.started');

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
}

/// Routes uncaught Flutter/Dart errors to the logger.
///
/// Two hooks cover the vast majority of failures on the Dart side:
///
/// - [FlutterError.onError] — synchronous errors raised by the framework
///   (widget build, layout, render, assertions).
/// - [PlatformDispatcher.onError] — asynchronous Dart errors that
///   escape every `Future`/`Stream`/zone above them (the catch-all of
///   last resort introduced in Flutter 3.3).
///
/// Native crashes (Swift/Obj-C on iOS, JVM on Android, FFI libs) bypass
/// both hooks — they kill the Dart isolate before either runs. Add
/// Crashlytics or Sentry if those start to matter.
void _installErrorHandlers(LoggerApplicationService logger) {
  final defaultOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    logger.error(
      'flutter.error',
      error: details.exception,
      stack: details.stack,
      attrs: {
        if (details.library != null) 'flutter.library': details.library!,
        if (details.context != null)
          'flutter.context': details.context!.toString(),
      },
    );
    // Keep the default behaviour (red error screen in debug, console
    // dump elsewhere) so we don't silently hide errors during dev.
    defaultOnError?.call(details);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    logger.error('dart.uncaught', error: error, stack: stack);
    // Return `true` to mark the error as handled. The app continues to
    // run rather than letting the error propagate to the platform.
    return true;
  };

  if (kDebugMode) {
    // Belt-and-braces: surface logger init in the console so the first
    // log line of every dev run is visible.
    debugPrint('logger: error handlers installed');
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  /// Clé du navigateur racine : permet de renvoyer au login depuis l'extérieur
  /// de l'arbre de widgets (révocation de session sur 401).
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final logger = ref.read(loggerProvider);
    switch (state) {
      case AppLifecycleState.resumed:
        logger.info('app.resumed');
      case AppLifecycleState.paused:
        // Flush so buffered logs ship before the OS may suspend us.
        logger.info('app.paused');
        logger.flush();
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observer le mode de thème actuel
    final themeModeAsync = ref.watch(themeModeProvider);

    // Un 401 invalid_token sur une route protégée révoque la session : on
    // redemande un OTP pour le numéro connu et on renvoie directement à l'écran
    // OTP (cf. API.md), sans faire ressaisir le numéro.
    ref.listen(sessionRevocationProvider, (_, _) async {
      final started = await ref
          .read(authNotifierProvider.notifier)
          .reauthenticate();
      if (started) {
        MyApp.navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthGate()),
          (route) => false,
        );
      }
    });

    return themeModeAsync.when(
      data: (appThemeMode) => MaterialApp(
        title: 'Songbook',
        navigatorKey: MyApp.navigatorKey,
        theme: AppThemeData.buildLightTheme(),
        darkTheme: AppThemeData.buildDarkTheme(),
        themeMode: AppThemeData.toFlutterThemeMode(appThemeMode),
        home: const AuthGate(),
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
