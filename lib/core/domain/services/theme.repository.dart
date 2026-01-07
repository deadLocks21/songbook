import 'package:songbook/core/domain/model/theme_mode.dart';

/// Interface pour la gestion de la persistance du mode de thème
abstract interface class ThemeRepository {
  /// Récupère le mode de thème actuellement sauvegardé
  ///
  /// Retourne [AppThemeMode.system] par défaut si aucune préférence n'est sauvegardée
  Future<AppThemeMode> getThemeMode();

  /// Sauvegarde le mode de thème choisi par l'utilisateur
  Future<void> setThemeMode(AppThemeMode mode);
}
