import 'package:songbook/core/domain/model/uuid_value.dart';

/// Représente un recueil : une collection de chants.
///
/// Le [code] sert d'identifiant fonctionnel pour filtrer les chants
/// (cf. `/api/songs?recueils=CODE`) et le champ `recueils` de chaque chant.
class Recueil {
  final UuidValue id;
  final String code;
  final String name;

  Recueil({required this.id, required this.code, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Recueil && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
