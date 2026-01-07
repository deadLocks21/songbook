import 'package:flutter/material.dart';
import 'package:songbook/core/domain/model/theme_mode.dart';

/// Service de configuration des thèmes de l'application
class AppThemeData {
  /// Couleur de base pour les thèmes
  static const Color seedColor = Colors.deepPurple;

  /// Construit le thème clair de l'application
  static ThemeData buildLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    );
  }

  /// Construit le thème sombre de l'application
  static ThemeData buildDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
  }

  /// Convertit AppThemeMode (domain) en ThemeMode de Flutter
  static ThemeMode toFlutterThemeMode(AppThemeMode appThemeMode) {
    return switch (appThemeMode) {
      AppThemeMode.light => ThemeMode.light,
      AppThemeMode.dark => ThemeMode.dark,
      AppThemeMode.system => ThemeMode.system,
    };
  }
}
