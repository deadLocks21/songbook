import 'package:songbook/core/domain/model/display_resource_type.dart';

/// Interface pour la gestion de la persistance des paramètres de l'application
abstract interface class SettingsRepository {
  /// Récupère l'URL du backend actuellement sauvegardée
  ///
  /// Retourne une URL par défaut si aucune URL personnalisée n'est configurée
  Future<String> getBackendUrl();

  /// Sauvegarde l'URL du backend configurée par l'utilisateur
  Future<void> setBackendUrl(String url);

  /// Récupère les codes des recueils dont les partitions doivent être
  /// téléchargées et mises en cache localement lors de la synchronisation.
  ///
  /// Retourne une liste vide si aucun recueil n'a été sélectionné.
  Future<List<String>> getSelectedRecueils();

  /// Sauvegarde les codes des recueils sélectionnés pour le cache local.
  Future<void> setSelectedRecueils(List<String> codes);

  /// Ordre de préférence des types de ressources affichées : le premier type
  /// disponible pour un chant est affiché par défaut.
  ///
  /// Retourne un ordre par défaut ([DisplayResourceType.partition] puis
  /// [DisplayResourceType.chordPro]) si aucune préférence n'est sauvegardée.
  Future<List<DisplayResourceType>> getResourceDisplayOrder();

  /// Sauvegarde l'ordre de préférence des types de ressources affichées.
  Future<void> setResourceDisplayOrder(List<DisplayResourceType> order);
}
