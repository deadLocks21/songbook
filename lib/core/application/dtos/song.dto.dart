import 'package:songbook/core/application/dtos/resource.dto.dart';
import 'package:songbook/core/domain/model/song.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';

/// DTO pour représenter un chant dans l'UI.
/// Contient les informations du chant et ses ressources.
class SongDto {
  final String id;
  final String code;
  final String name;
  final DateTime updatedAt;
  final List<ResourceDto> resources;

  const SongDto({
    required this.id,
    required this.code,
    required this.name,
    required this.updatedAt,
    required this.resources,
  });

  /// Crée un SongDto depuis une entité Song domain.
  factory SongDto.fromDomain(Song song) {
    return SongDto(
      id: song.id.value,
      code: song.code,
      name: song.name,
      updatedAt: song.updatedAt,
      resources: song.resources.map(ResourceDto.fromDomain).toList(),
    );
  }

  /// Convertit ce DTO en entité Song domain.
  Song toDomain() {
    return Song(
      id: UuidValue.parse(id),
      code: code,
      name: name,
      updatedAt: updatedAt,
      resources: resources.map((dto) => dto.toDomain()).toList(),
    );
  }

  /// Convertit ce DTO en JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'updatedAt': updatedAt.toIso8601String(),
      'resources': resources.map((r) => r.toJson()).toList(),
    };
  }

  /// Crée un SongDto depuis du JSON.
  factory SongDto.fromJson(Map<String, dynamic> json) {
    return SongDto(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      resources: (json['resources'] as List<dynamic>)
          .map((r) => ResourceDto.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}
