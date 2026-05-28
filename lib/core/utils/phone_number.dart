/// Helpers de normalisation des numéros de téléphone vers le format **E.164**
/// attendu par l'API (mobile français : `+33` suivi de `6`/`7` puis 8 chiffres,
/// cf. API.md).
class PhoneNumber {
  const PhoneNumber._();

  /// Normalise un numéro saisi vers l'E.164 français quand c'est possible.
  ///
  /// - `06 12 34 56 78` / `0612345678` → `+33612345678`
  /// - `+33612345678` → inchangé
  /// - tout autre format est renvoyé débarrassé de ses séparateurs, en laissant
  ///   le backend trancher sur sa validité.
  static String toE164(String input) {
    final cleaned = input.replaceAll(RegExp(r'[\s.\-()]'), '');
    if (cleaned.startsWith('+')) return cleaned;
    // Forme nationale française (0[67]XXXXXXXX) → +33[67]XXXXXXXX.
    if (cleaned.startsWith('0') && cleaned.length == 10) {
      return '+33${cleaned.substring(1)}';
    }
    return cleaned;
  }
}
