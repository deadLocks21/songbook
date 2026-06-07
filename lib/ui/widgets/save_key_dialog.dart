import 'package:flutter/material.dart';

/// Choix de l'utilisateur dans la boîte de dialogue de sauvegarde de tonalité.
enum SaveKeyAction { save, discard, cancel }

/// Demande s'il faut enregistrer la tonalité modifiée d'un chant dans une liste.
/// Utilisé à l'identique en mode présentation et en mode édition de liste.
Future<SaveKeyAction?> showSaveKeyDialog(BuildContext context) {
  return showDialog<SaveKeyAction>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Tonalité modifiée'),
      content: const Text(
        'Enregistrer cette tonalité pour ce chant dans cette liste ?',
      ),
      actions: [
        TextButton(
          key: const Key('cancelSaveKeyButton'),
          onPressed: () => Navigator.pop(context, SaveKeyAction.cancel),
          child: const Text('Annuler'),
        ),
        TextButton(
          key: const Key('discardSaveKeyButton'),
          onPressed: () => Navigator.pop(context, SaveKeyAction.discard),
          child: const Text('Ne pas enregistrer'),
        ),
        TextButton(
          key: const Key('confirmSaveKeyButton'),
          onPressed: () => Navigator.pop(context, SaveKeyAction.save),
          child: const Text('Enregistrer'),
        ),
      ],
    ),
  );
}
