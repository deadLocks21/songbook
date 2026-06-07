import 'package:chord_pro/chord_pro.dart';

/// Tonalité obtenue en transposant [key] de [semitones] demi-tons, ou `null`
/// quand la tonalité d'origine est inconnue ou n'est pas en notation à lettres
/// (Nashville/romaine) — l'appelant retombe alors sur l'affichage « +X / -X ».
///
/// Calculée comme le package (`Song.transposed`, dièses par défaut), pour rester
/// cohérent avec les accords et la tonalité de l'en-tête déjà transposés.
String? transposedKeyLabel(String? key, int semitones) {
  if (key == null) return null;
  final chord = Chord.tryParse(key);
  if (chord == null || chord.system != ChordSystem.letter) return null;
  return chord.transpose(semitones).raw;
}
