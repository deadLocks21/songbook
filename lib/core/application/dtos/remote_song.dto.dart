import 'package:songbook/core/domain/model/remote_song.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';

/// DTO pour parser le JSON de l'API pour un song distant.
class RemoteSongDto {
  final String id;
  final String code;
  final String name;
  final DateTime updatedAt;
  final List<RemoteResourceDto> resources;
  final List<String> recueils;

  const RemoteSongDto({
    required this.id,
    required this.code,
    required this.name,
    required this.updatedAt,
    required this.resources,
    this.recueils = const [],
  });

  /// Crée un RemoteSongDto depuis du JSON.
  factory RemoteSongDto.fromJson(Map<String, dynamic> json) {
    return RemoteSongDto(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      resources: (json['resources'] as List<dynamic>)
          .map((r) => RemoteResourceDto.tryFromJson(r as Map<String, dynamic>))
          .whereType<RemoteResourceDto>()
          .toList(),
      recueils:
          (json['recueils'] as List<dynamic>?)?.cast<String>() ?? const [],
    );
  }

  /// Convertit ce DTO vers le domain RemoteSong.
  RemoteSong toDomain() {
    return RemoteSong(
      id: UuidValue.parse(id),
      code: code,
      name: name,
      updatedAt: updatedAt,
      resources: resources.map((r) => r.toDomain()).toList(),
      recueils: recueils,
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
      'recueils': recueils,
    };
  }
}

/// DTO scellé pour parser les ressources distantes depuis le JSON.
sealed class RemoteResourceDto {
  const RemoteResourceDto();

  String get id;
  String get name;

  /// Crée un RemoteResourceDto depuis du JSON.
  /// Utilise le champ 'type' pour déterminer le type concret.
  factory RemoteResourceDto.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'image' => RemoteImageResourceDto.fromJson(json),
      'pdf' => RemotePdfResourceDto.fromJson(json),
      _ => throw ArgumentError('Unknown remote resource type: $type'),
    };
  }

  /// Comme [fromJson] mais renvoie `null` pour un type non géré (lyrics, audio,
  /// chords, …) au lieu de lever : l'app n'affiche que les images/PDF, les
  /// autres ressources sont ignorées sans faire échouer la synchronisation.
  static RemoteResourceDto? tryFromJson(Map<String, dynamic> json) {
    return switch (json['type'] as String?) {
      'image' => RemoteImageResourceDto.fromJson(json),
      'pdf' => RemotePdfResourceDto.fromJson(json),
      _ => null,
    };
  }

  /// Convertit ce DTO vers le domain RemoteResource.
  RemoteResource toDomain();

  /// Convertit ce DTO en JSON.
  Map<String, dynamic> toJson();
}

/// DTO pour une ressource image distante.
class RemoteImageResourceDto extends RemoteResourceDto {
  @override
  final String id;
  @override
  final String name;
  final List<String> imageUrls;

  const RemoteImageResourceDto({
    required this.id,
    required this.name,
    required this.imageUrls,
  });

  factory RemoteImageResourceDto.fromJson(Map<String, dynamic> json) {
    return RemoteImageResourceDto(
      id: json['id'] as String,
      // L'API ne fournit pas de name, on utilise l'id par défaut
      name: json['name'] as String? ?? json['id'] as String,
      // L'API utilise 'data' au lieu de 'imageUrls'
      imageUrls:
          (json['data'] as List<dynamic>?)?.cast<String>() ??
          (json['imageUrls'] as List<dynamic>?)?.cast<String>() ??
          [],
    );
  }

  @override
  RemoteResource toDomain() {
    return RemoteImageResource(
      id: UuidValue.parse(id),
      name: name,
      imageUrls: imageUrls,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'type': 'image', 'id': id, 'name': name, 'imageUrls': imageUrls};
  }
}

/// DTO pour une ressource PDF distante.
class RemotePdfResourceDto extends RemoteResourceDto {
  @override
  final String id;
  @override
  final String name;
  final String pdfUrl;

  const RemotePdfResourceDto({
    required this.id,
    required this.name,
    required this.pdfUrl,
  });

  factory RemotePdfResourceDto.fromJson(Map<String, dynamic> json) {
    return RemotePdfResourceDto(
      id: json['id'] as String,
      name: json['name'] as String,
      pdfUrl: json['pdfUrl'] as String,
    );
  }

  @override
  RemoteResource toDomain() {
    return RemotePdfResource(
      id: UuidValue.parse(id),
      name: name,
      pdfUrl: pdfUrl,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'type': 'pdf', 'id': id, 'name': name, 'pdfUrl': pdfUrl};
  }
}
