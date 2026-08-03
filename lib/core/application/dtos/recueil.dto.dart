import 'package:songbook/core/domain/model/recueil.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';

/// DTO pour parser le JSON de l'API pour un recueil.
class RecueilDto {
  final String id;
  final String code;
  final String name;

  const RecueilDto({required this.id, required this.code, required this.name});

  factory RecueilDto.fromJson(Map<String, dynamic> json) {
    return RecueilDto(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
    );
  }

  Recueil toDomain() {
    return Recueil(id: UuidValue.parse(id), code: code, name: name);
  }
}
