import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/ui/pages/sync/providers/sync_state.provider.dart';

/// Modal pour saisir le mot de passe d'authentification API
class PasswordInputDialog extends ConsumerStatefulWidget {
  const PasswordInputDialog({super.key});

  @override
  ConsumerState<PasswordInputDialog> createState() =>
      _PasswordInputDialogState();
}

class _PasswordInputDialogState extends ConsumerState<PasswordInputDialog> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _rememberPassword = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Authentification requise'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Le serveur nécessite un mot de passe pour accéder aux données.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                hintText: 'Entrez votre mot de passe',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  tooltip: _obscurePassword
                      ? 'Afficher le mot de passe'
                      : 'Masquer le mot de passe',
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le mot de passe est requis';
                }
                return null;
              },
              autofocus: true,
              onFieldSubmitted: _isLoading ? null : (_) => _submitPassword(),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: Text(
                'Mémoriser le mot de passe',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              subtitle: Text(
                'Le mot de passe sera stocké de manière sécurisée',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              value: _rememberPassword,
              onChanged: (value) {
                setState(() {
                  _rememberPassword = value ?? true;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : _cancel,
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submitPassword,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Valider'),
        ),
      ],
    );
  }

  void _submitPassword() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Note: Le stockage du mot de passe est géré automatiquement par submitPassword
    // même si rememberPassword est false, car c'est nécessaire pour la requête en cours
    ref.read(syncStateNotifierProvider.notifier).submitPassword(password);

    // Fermer la modal - l'état sera mis à jour automatiquement
    Navigator.of(context).pop();
  }

  void _cancel() {
    ref.read(syncStateNotifierProvider.notifier).cancelPasswordInput();
    Navigator.of(context).pop();
  }
}
