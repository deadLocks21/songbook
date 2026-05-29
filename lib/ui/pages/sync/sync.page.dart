import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/infrastructure/settings/providers/settings.service_provider.dart';
import 'package:songbook/ui/pages/home/home.page.dart';
import 'package:songbook/ui/pages/sync/providers/sync_state.provider.dart';

/// Écran de synchronisation de la liste des chants.
///
/// La synchronisation est **automatique et silencieuse** : on rafraîchit la
/// liste depuis le serveur puis on continue. En cas d'échec réseau, une popup
/// informe l'utilisateur, puis on poursuit avec les données locales.
///
/// - Au démarrage ([isStartupSync] = true) : succès comme échec mènent à la
///   home.
/// - Depuis les réglages ([isStartupSync] = false) : on revient à l'écran
///   précédent en signalant le résultat.
class SyncPage extends ConsumerStatefulWidget {
  final bool isStartupSync;

  const SyncPage({super.key, this.isStartupSync = false});

  @override
  ConsumerState<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends ConsumerState<SyncPage> {
  /// Évite un double effet de fin (navigation / popup) pour une même synchro.
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runSync());
  }

  /// Lance la synchro puis **navigue d'après son résultat** (le `Future` qu'on
  /// attend), et non en observant une transition d'état.
  ///
  /// `syncStateNotifierProvider` est global : son état reste `SyncSuccess`
  /// d'une synchro à l'autre. Or une synchro **in-memory** est si rapide que
  /// `SyncInProgress → SyncSuccess` se produit dans un même cycle de microtasks ;
  /// si l'état précédent était déjà `SyncSuccess` (relogin, sync manuelle…),
  /// Riverpod ne voit aucun changement net et un `ref.listen` ne se déclenche
  /// jamais → l'écran resterait bloqué. Attendre le `Future` est déterministe,
  /// quelle que soit la vitesse de la synchro (in-memory comme réseau réel).
  Future<void> _runSync() async {
    final backendUrl = await ref.read(backendUrlProvider.future);
    if (!mounted) return;
    // En mode démo (aucune URL ou « memory »), la synchro tourne sur les repos
    // en mémoire ; l'URL vide est ignorée. Cf. [inMemoryModeProvider].
    await ref.read(syncStateNotifierProvider.notifier).sync(backendUrl ?? '');
    if (!mounted) return;

    switch (ref.read(syncStateProvider)) {
      case SyncSuccess():
        _finish(success: true);
      case SyncFailure(:final message):
        await _showFailureDialog(message);
      case SyncInProgress() || SyncCachingPartitions():
        // Cas 401 (backend réel) : `sync()` sort sans état terminal et la
        // ré-authentification (intercepteur Dio) pilote la navigation.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(syncStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Synchronisation'),
        automaticallyImplyLeading: !widget.isStartupSync,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              _labelFor(state),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  /// Libellé affiché selon la phase de synchronisation en cours.
  String _labelFor(SyncState state) {
    if (state is SyncCachingPartitions) {
      if (state.total == 0) {
        return 'Téléchargement des chants…';
      }
      return 'Téléchargement des chants… '
          '${state.done}/${state.total}';
    }
    return 'Mise à jour de la liste des chants…';
  }

  Future<void> _showFailureDialog(String message) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.cloud_off, color: Theme.of(context).colorScheme.error),
        title: const Text('Synchronisation impossible'),
        content: Text(
          '$message\n\nLes chants déjà enregistrés restent accessibles.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continuer'),
          ),
        ],
      ),
    );

    _finish(success: false);
  }

  /// Termine l'écran : navigation vers la home au démarrage, retour à l'écran
  /// précédent sinon.
  void _finish({required bool success}) {
    if (!mounted || _finished) return;
    _finished = true;

    if (widget.isStartupSync) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    } else {
      Navigator.of(context).pop(success);
    }
  }
}
