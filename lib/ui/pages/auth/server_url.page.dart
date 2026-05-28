import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/utils/backend_url.dart';
import 'package:songbook/infrastructure/settings/providers/settings.service_provider.dart';

/// Ouvre la configuration de l'URL du serveur dans une modale (bottom sheet),
/// accessible depuis la roue crantée de l'écran de connexion.
Future<void> showServerUrlSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _ServerUrlSheet(),
  );
}

/// Contenu de la modale de configuration de l'URL du serveur.
///
/// Réutilise la validation et le stockage existants ([BackendUrl] +
/// `backendUrlProvider`) : seul le domaine (origine) est conservé.
class _ServerUrlSheet extends ConsumerStatefulWidget {
  const _ServerUrlSheet();

  @override
  ConsumerState<_ServerUrlSheet> createState() => _ServerUrlSheetState();
}

class _ServerUrlSheetState extends ConsumerState<_ServerUrlSheet> {
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

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 8,
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
    );
  }
}
