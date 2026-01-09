import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/infrastructure/settings/providers/settings.usecases_provider.dart';
import 'package:songbook/ui/pages/home/home_page.dart';
import 'package:songbook/ui/pages/sync/providers/sync_state.provider.dart';
import 'package:songbook/ui/pages/sync/widgets/diff_summary.dart';

/// Page de synchronisation avec le serveur
class SyncPage extends ConsumerStatefulWidget {
  final bool isStartupSync;

  const SyncPage({
    super.key,
    this.isStartupSync = false, // false = mode normal (depuis settings)
  });

  @override
  ConsumerState<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends ConsumerState<SyncPage> {
  // Flag pour savoir si le calcul initial du diff a été lancé
  bool _initialComputeStarted = false;

  @override
  void initState() {
    super.initState();
    // Démarre automatiquement le calcul du diff
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Récupérer l'URL depuis le provider
      final backendUrl = await ref.read(backendUrlProvider.future);
      if (backendUrl != null && backendUrl.isNotEmpty) {
        _initialComputeStarted = true;
        ref.read(syncStateNotifierProvider.notifier).computeDiff(backendUrl);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(syncStateProvider);

    // En mode startup, si le calcul initial a été fait ET qu'il n'y a pas de différence (SyncInitial),
    // naviguer automatiquement vers HomePage
    if (widget.isStartupSync &&
        syncState is SyncInitial &&
        _initialComputeStarted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToHome();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Synchronisation'),
        // Bouton retour seulement quand on vient des settings (pas au démarrage)
        automaticallyImplyLeading: !widget.isStartupSync,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildContent(syncState),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(SyncState state) {
    return switch (state) {
      SyncInitial() => _buildInitialState(),
      SyncComputing() => _buildComputingState(),
      SyncDiffComputed() => _buildDiffComputedState(state),
      SyncExecuting() => _buildExecutingState(),
      SyncSuccess() => _buildSuccessState(),
      SyncError() => _buildErrorState(state),
    };
  }

  Widget _buildInitialState() {
    // État temporaire, devrait rapidement passer à computing
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Initialisation...'),
      ],
    );
  }

  Widget _buildComputingState() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text(
          'Vérification des modifications...',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDiffComputedState(SyncDiffComputed state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.info_outline, size: 64, color: Colors.blue),
        const SizedBox(height: 16),
        const Text(
          'Modifications détectées',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        DiffSummary(diff: state.diff),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: widget.isStartupSync
                  ? _navigateToHome
                  : () => Navigator.of(context).pop(),
              child: Text(
                widget.isStartupSync
                    ? 'Continuer sans synchroniser'
                    : 'Annuler',
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () => ref
                  .read(syncStateNotifierProvider.notifier)
                  .executeSync(state.diff),
              child: const Text('Synchroniser'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExecutingState() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text(
          'Synchronisation en cours...',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    // En mode startup, naviguer automatiquement vers HomePage
    if (widget.isStartupSync) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToHome();
      });
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, size: 64, color: Colors.green),
        const SizedBox(height: 16),
        const Text(
          'Synchronisation terminée avec succès',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        // En mode startup, pas de bouton, navigation automatique
        if (!widget.isStartupSync)
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Retour'),
          ),
      ],
    );
  }

  Widget _buildErrorState(SyncError state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error, size: 64, color: Colors.red),
        const SizedBox(height: 16),
        const Text(
          'Erreur de synchronisation',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Text(
          state.message,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: widget.isStartupSync
                  ? _navigateToHome
                  : () => Navigator.of(context).pop(),
              child: Text(
                widget.isStartupSync
                    ? 'Continuer sans synchroniser'
                    : 'Annuler',
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () async {
                // Récupérer l'URL depuis le provider pour le retry
                final backendUrl = await ref.read(backendUrlProvider.future);
                if (backendUrl != null && backendUrl.isNotEmpty) {
                  ref
                      .read(syncStateNotifierProvider.notifier)
                      .computeDiff(backendUrl);
                }
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }
}
