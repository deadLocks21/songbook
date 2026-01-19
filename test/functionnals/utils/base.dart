import 'package:flutter_test/flutter_test.dart';

import 'types.dart';

/// Classe de base pour toutes les actions de page.
/// Gère l'accumulation et l'exécution différée des commandes.
abstract class FluentActionsBase {
  final IFluentNavigation navigation;
  final WidgetTester tester;
  final List<FluentCommand> commands = [];

  FluentActionsBase(this.navigation, this.tester);

  /// Ajoute une commande à la file d'exécution.
  void addCommand(FluentCommand command) {
    commands.add(command);
  }

  /// Exécute toutes les commandes accumulées séquentiellement.
  Future<void> execute() async {
    for (final command in commands) {
      await command.execute();
    }
    commands.clear();
  }
}
