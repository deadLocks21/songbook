import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:songbook/ui/pages/auth/otp.page.dart';
import 'package:songbook/ui/pages/auth/phone_entry.page.dart';
import 'package:songbook/ui/pages/auth/providers/auth_state.provider.dart';
import 'package:songbook/ui/pages/sync/sync.page.dart';

/// Racine de l'application : ne laisse accéder à la synchronisation puis à la
/// home qu'une fois l'utilisateur authentifié.
///
/// Tant que l'état n'est pas [AuthAuthenticated], seul le flux
/// d'authentification (numéro de téléphone puis OTP) est affiché : c'est ce
/// gate, côté client, qui protège l'accès aux chants — les endpoints, eux, ne
/// sont pas authentifiés.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return switch (authState) {
      // Vérification d'une session persistée au démarrage.
      AuthInitializing() => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      AuthUnauthenticated() => const PhoneEntryPage(),
      AuthOtpPending() => const OtpPage(),
      // Une fois authentifié, on reprend le flux de démarrage habituel : la
      // synchronisation silencieuse mène ensuite à la home.
      AuthAuthenticated() => const SyncPage(isStartupSync: true),
    };
  }
}
