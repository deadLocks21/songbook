import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/core/application/services/song_list_sharing.service.dart';
import 'package:songbook/infrastructure/song_list/providers/song_list_sharing.provider.dart';

/// Saisie d'un code de partage pour suivre la liste de quelqu'un d'autre.
///
/// Les erreurs restent **dans** la boîte : un code refusé se corrige sur place,
/// alors que fermer pour afficher un message obligerait à tout retaper.
///
/// Se referme en rendant le [FollowOutcome] quand l'échange a abouti ; `null`
/// si l'utilisateur renonce.
class FollowSongListDialog extends ConsumerStatefulWidget {
  const FollowSongListDialog({super.key});

  @override
  ConsumerState<FollowSongListDialog> createState() =>
      _FollowSongListDialogState();
}

class _FollowSongListDialogState extends ConsumerState<FollowSongListDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final busy = ref.watch(songListSharingProvider);

    return AlertDialog(
      title: const Text('Suivre une liste'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saisissez le code que vous avez reçu. Vous en obtiendrez une copie, '
            'que vous pourrez modifier librement.',
          ),
          const SizedBox(height: 16.0),
          TextField(
            key: const Key('followCodeField'),
            controller: _controller,
            autofocus: true,
            enabled: !busy,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'Code de partage',
              hintText: 'K7Q2M9XZ',
              errorText: _error,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: busy ? null : (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          key: const Key('cancelFollowButton'),
          onPressed: busy ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        TextButton(
          key: const Key('confirmFollowButton'),
          onPressed: busy ? null : _submit,
          child: busy
              ? const SizedBox(
                  width: 16.0,
                  height: 16.0,
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                )
              : const Text('Suivre'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Saisissez un code.');
      return;
    }

    setState(() => _error = null);

    final result = await ref
        .read(songListSharingProvider.notifier)
        .follow(code: code);

    if (!mounted) return;

    switch (result) {
      case FollowSucceeded(:final outcome):
        Navigator.pop(context, outcome);
      case FollowRejected():
        setState(
          () => _error = 'Ce code ne correspond à aucune liste partagée.',
        );
      case FollowFailed():
        setState(
          () => _error = 'Serveur injoignable. Réessayez dans un instant.',
        );
    }
  }
}
