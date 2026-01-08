import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/ui/pages/sync/providers/sync_state.provider.dart';
import 'package:songbook/ui/pages/sync/widgets/diff_summary.dart';

/// Page de synchronisation avec le serveur
class SyncPage extends ConsumerStatefulWidget {
  final String backendUrl;

  const SyncPage({super.key, required this.backendUrl});

  @override
  ConsumerState<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends ConsumerState<SyncPage> {
  @override
  void initState() {
    super.initState();
    // Démarre automatiquement le calcul du diff
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(syncStateNotifierProvider.notifier)
          .computeDiff(widget.backendUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(syncStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Synchronisation'),
        // Pas de bouton retour automatique, on gère la navigation manuellement
        automaticallyImplyLeading: false,
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () => ref
                  .read(syncStateNotifierProvider.notifier)
                  .computeDiff(widget.backendUrl),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ],
    );
  }
}
