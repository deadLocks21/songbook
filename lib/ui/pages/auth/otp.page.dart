import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/ui/pages/auth/providers/auth_state.provider.dart';

/// Seconde étape de l'authentification : l'utilisateur saisit le code reçu.
class OtpPage extends ConsumerStatefulWidget {
  const OtpPage({super.key});

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends ConsumerState<OtpPage> {
  final _otpController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _backToPhoneEntry() {
    ref.read(authNotifierProvider.notifier).backToPhoneEntry();
  }

  Future<void> _submit() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      setState(() => _error = 'Saisissez le code reçu');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    // En cas de succès, l'état passe à `AuthAuthenticated` et le gate remplace
    // cette page par la synchronisation : on évite de toucher au state après.
    final error = await ref.read(authNotifierProvider.notifier).verifyOtp(otp);

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Le numéro en attente de validation, pour le rappeler à l'utilisateur.
    final authState = ref.watch(authNotifierProvider);
    final phoneNumber = authState is AuthOtpPending
        ? authState.phoneNumber
        : '';

    // Cette page est la route racine pendant l'auth : on intercepte le retour
    // système pour revenir à la saisie du numéro plutôt que quitter l'app.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _backToPhoneEntry();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            key: const Key('otpBackButton'),
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Retour',
            onPressed: _isSubmitting ? null : _backToPhoneEntry,
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                Icon(
                  Icons.sms,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Code de vérification',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  phoneNumber.isEmpty
                      ? 'Saisissez le code à 6 chiffres.'
                      : 'Saisissez le code envoyé au $phoneNumber.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withValues(
                      alpha: 0.7,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  key: const Key('otpField'),
                  controller: _otpController,
                  autofocus: true,
                  enabled: !_isSubmitting,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  textInputAction: TextInputAction.done,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(letterSpacing: 8),
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: '000000',
                    counterText: '',
                    border: const OutlineInputBorder(),
                    errorText: _error,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('verifyOtpButton'),
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Valider'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
