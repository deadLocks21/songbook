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
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Initialisation...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComputingState() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Vérification des modifications...',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiffComputedState(SyncDiffComputed state) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sync_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Modifications détectées',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Des changements nécessitent une synchronisation',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            DiffSummary(diff: state.diff),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
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
                FilledButton.icon(
                  onPressed: () => ref
                      .read(syncStateNotifierProvider.notifier)
                      .executeSync(state.diff),
                  icon: const Icon(Icons.sync),
                  label: const Text('Synchroniser'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutingState() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Synchronisation en cours...',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Veuillez patienter',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    // En mode startup, naviguer automatiquement vers HomePage
    if (widget.isStartupSync) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToHome();
      });
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 48,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Synchronisation réussie',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Toutes les modifications ont été synchronisées',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // En mode startup, pas de bouton, navigation automatique
            if (!widget.isStartupSync)
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Retour'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(SyncError state) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Erreur de synchronisation',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.errorContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                state.message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
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
                FilledButton.icon(
                  onPressed: () async {
                    // Récupérer l'URL depuis le provider pour le retry
                    final backendUrl = await ref.read(
                      backendUrlProvider.future,
                    );
                    if (backendUrl != null && backendUrl.isNotEmpty) {
                      ref
                          .read(syncStateNotifierProvider.notifier)
                          .computeDiff(backendUrl);
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          ],
        ),
      ),
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
