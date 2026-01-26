import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/infrastructure/settings/providers/settings.usecases_provider.dart';
import 'package:songbook/ui/pages/home/home.page.dart';
import 'package:songbook/ui/pages/sync/providers/sync_state.provider.dart';
import 'package:songbook/ui/pages/sync/widgets/diff_summary.widget.dart';
import 'package:songbook/ui/pages/sync/widgets/password_input_dialog.widget.dart';

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
  @override
  void initState() {
    super.initState();
    // Démarre automatiquement le calcul du diff
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Récupérer l'URL depuis le provider
      final backendUrl = await ref.read(backendUrlProvider.future);
      if (backendUrl != null && backendUrl.isNotEmpty) {
        ref.read(syncStateNotifierProvider.notifier).computeDiff(backendUrl);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(syncStateProvider);

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
      SyncComputing() => _buildComputingState(state),
      SyncUpToDate() => _buildUpToDateState(),
      SyncDiffComputed() => _buildDiffComputedState(state),
      SyncExecuting() => _buildExecutingState(state),
      SyncSuccess() => _buildSuccessState(),
      SyncError() => _buildErrorState(state),
      SyncPasswordRequired() => _buildPasswordRequiredState(),
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

  Widget _buildComputingState(SyncComputing state) {
    final progressPercent = (state.progress * 100).round();
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
              value: state.progress,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 8),
            Text(
              '$progressPercent%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpToDateState() {
    // En mode startup, naviguer immédiatement sans afficher le message
    if (widget.isStartupSync) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToHome();
      });
      // Afficher un état de chargement pendant la navigation
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
                'Chargement...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    // En mode normal, afficher le message "Tout est à jour"
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
              'Tout est à jour !',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Aucune modification à synchroniser',
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

  Widget _buildExecutingState(SyncExecuting state) {
    final progressPercent = (state.progress * 100).round();
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
              value: state.progress,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 8),
            Text(
              '$progressPercent%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
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
            FilledButton.icon(
              onPressed: () => _navigateToHome(),
              icon: const Icon(Icons.home),
              label: const Text('Voir les chants'),
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
                ).colorScheme.errorContainer.withAlpha(30),
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

  Widget _buildPasswordRequiredState() {
    // Afficher la modal de saisie du mot de passe
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible:
            false, // Empêcher la fermeture en cliquant à l'extérieur
        builder: (context) => const PasswordInputDialog(),
      );
    });

    // Afficher un état de chargement pendant que la modal s'affiche
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Authentification requise',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Un mot de passe est nécessaire pour accéder aux données.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false, // Supprime toutes les routes précédentes
      );
    }
  }
}
