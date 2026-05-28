import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/ui/pages/auth/providers/auth_state.provider.dart';
import 'package:songbook/ui/pages/auth/server_url.page.dart';

/// Première étape de l'authentification : l'utilisateur saisit son numéro de
/// téléphone pour recevoir un code à usage unique.
///
/// La roue crantée en haut à droite ouvre la configuration de l'URL du serveur.
class PhoneEntryPage extends ConsumerStatefulWidget {
  const PhoneEntryPage({super.key});

  @override
  ConsumerState<PhoneEntryPage> createState() => _PhoneEntryPageState();
}

class _PhoneEntryPageState extends ConsumerState<PhoneEntryPage> {
  final _phoneController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _openServerSettings() {
    return Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (context) => const ServerUrlPage()),
    );
  }

  Future<void> _submit() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _error = 'Saisissez votre numéro de téléphone');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    // En cas de succès, l'état passe à `AuthOtpPending` et le gate remplace
    // cette page par l'écran OTP : on évite donc de toucher au state après.
    final error = await ref
        .read(authNotifierProvider.notifier)
        .requestOtp(phone);

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            key: const Key('serverUrlSettingsButton'),
            icon: const Icon(Icons.settings),
            tooltip: 'Configurer le serveur',
            onPressed: _isSubmitting ? null : _openServerSettings,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(24),
            shrinkWrap: true,
            children: [
              Icon(
                Icons.phone_android,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Votre numéro de téléphone',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Nous vous enverrons un code de vérification.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.7,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                key: const Key('phoneNumberField'),
                controller: _phoneController,
                autofocus: true,
                enabled: !_isSubmitting,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9 .\-+]')),
                ],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: 'Numéro de téléphone',
                  hintText: '0612345678',
                  prefixIcon: const Icon(Icons.phone),
                  border: const OutlineInputBorder(),
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('requestOtpButton'),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Recevoir le code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
