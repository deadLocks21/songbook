/// Types de ressources d'un chant affichables dans la visionneuse.
///
/// Leur ordre dans la préférence « Priorité d'affichage » détermine quelle vue
/// est sélectionnée par défaut quand un chant possède plusieurs ressources : le
/// premier type disponible dans l'ordre l'emporte (cf. `SettingsRepository`).
enum DisplayResourceType {
  /// Partition image (une ou plusieurs pages).
  partition,

  /// Fichier ChordPro (accords + paroles).
  chordPro,
}
