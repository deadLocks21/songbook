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
  /// Empêche de relancer plusieurs effets (popup, navigation) pour un même
  /// état terminal.
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final backendUrl = await ref.read(backendUrlProvider.future);
      if (!mounted) return;
      if (backendUrl == null || backendUrl.isEmpty) {
        // Aucun serveur configuré : rien à synchroniser, on continue.
        _finish(success: false);
        return;
      }
      ref.read(syncStateNotifierProvider.notifier).sync(backendUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SyncState>(syncStateProvider, (previous, next) {
      switch (next) {
        case SyncSuccess():
          _finish(success: true);
        case SyncFailure(:final message):
          _showFailureDialog(message);
        case SyncInProgress():
          _handled = false;
        case SyncCachingPartitions():
          _handled = false;
      }
    });

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
    if (_handled || !mounted) return;
    _handled = true;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.cloud_off,
          color: Theme.of(context).colorScheme.error,
        ),
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
    if (!mounted) return;

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
