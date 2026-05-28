import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/utils/backend_url.dart';
import 'package:songbook/infrastructure/settings/providers/settings.service_provider.dart';

/// Configuration de l'URL du serveur, accessible depuis la roue crantée de
/// l'écran de connexion.
///
/// Réutilise la validation et le stockage existants ([BackendUrl] +
/// `backendUrlProvider`) : seul le domaine (origine) est conservé.
class ServerUrlPage extends ConsumerStatefulWidget {
  const ServerUrlPage({super.key});

  @override
  ConsumerState<ServerUrlPage> createState() => _ServerUrlPageState();
}

class _ServerUrlPageState extends ConsumerState<ServerUrlPage> {
  final _urlController = TextEditingController();
  bool _seeded = false;
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final raw = _urlController.text.trim();
    final error = BackendUrl.validate(raw);
    if (error != null) {
      setState(() => _error = error);
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    await ref
        .read(backendUrlProvider.notifier)
        .setBackendUrl(BackendUrl.normalize(raw));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('URL du serveur enregistrée'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backendUrlAsync = ref.watch(backendUrlProvider);

    // Pré-remplir le champ avec l'URL actuelle, une seule fois au chargement.
    backendUrlAsync.whenData((url) {
      if (!_seeded) {
        _urlController.text = url ?? '';
        _seeded = true;
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Serveur')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(24),
            shrinkWrap: true,
            children: [
              Text(
                'URL du backend',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                key: const Key('serverUrlField'),
                controller: _urlController,
                enabled: !_isSaving,
                keyboardType: TextInputType.url,
                autocorrect: false,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
                decoration: InputDecoration(
                  hintText: 'https://songbook.dtfh.fr',
                  border: const OutlineInputBorder(),
                  errorText: _error,
                ),
                onChanged: (value) {
                  setState(() => _error = BackendUrl.validate(value.trim()));
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Saisissez uniquement le domaine de votre serveur '
                '(ex : https://songbook.dtfh.fr), sans chemin',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                key: const Key('serverUrlSaveButton'),
                onPressed: (_isSaving || _error != null) ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
