import 'package:songbook/core/domain/model/resource.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';

/// DTO scellé pour représenter une ressource d'un chant dans l'UI.
sealed class ResourceDto {
  const ResourceDto();

  String get id;
  String get name;

  /// Crée un ResourceDto depuis un Resource domain.
  /// Utilise pattern matching pour déterminer le type.
  factory ResourceDto.fromDomain(Resource resource) {
    return switch (resource) {
      ImageResource(imagePaths: final paths) => ImageResourceDto(
        id: resource.id.value,
        name: resource.name,
        imagePaths: paths,
      ),
      PdfResource(pdfPath: final path) => PdfResourceDto(
        id: resource.id.value,
        name: resource.name,
        pdfPath: path,
      ),
    };
  }

  /// Convertit ce DTO en entité domain.
  Resource toDomain();

  /// Convertit ce DTO en JSON.
  Map<String, dynamic> toJson();

  /// Crée un ResourceDto depuis du JSON.
  /// Utilise le champ 'type' pour déterminer le type concret.
  factory ResourceDto.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'image' => ImageResourceDto.fromJson(json),
      'pdf' => PdfResourceDto.fromJson(json),
      _ => throw ArgumentError('Unknown resource type: $type'),
    };
  }
}

/// DTO pour une ressource contenant des images.
class ImageResourceDto extends ResourceDto {
  @override
  final String id;
  @override
  final String name;
  final List<String> imagePaths;

  const ImageResourceDto({
    required this.id,
    required this.name,
    required this.imagePaths,
  });

  @override
  Resource toDomain() {
    return ImageResource(
      id: UuidValue.parse(id),
      name: name,
      imagePaths: imagePaths,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {'type': 'image', 'id': id, 'name': name, 'imagePaths': imagePaths};
  }

  factory ImageResourceDto.fromJson(Map<String, dynamic> json) {
    return ImageResourceDto(
      id: json['id'] as String,
      name: json['name'] as String,
      imagePaths: (json['imagePaths'] as List<dynamic>).cast<String>(),
    );
  }
}

/// DTO pour une ressource contenant un PDF.
class PdfResourceDto extends ResourceDto {
  @override
  final String id;
  @override
  final String name;
  final String pdfPath;

  const PdfResourceDto({
    required this.id,
    required this.name,
    required this.pdfPath,
  });

  @override
  Resource toDomain() {
    return PdfResource(id: UuidValue.parse(id), name: name, pdfPath: pdfPath);
  }

  @override
  Map<String, dynamic> toJson() {
    return {'type': 'pdf', 'id': id, 'name': name, 'pdfPath': pdfPath};
  }

  factory PdfResourceDto.fromJson(Map<String, dynamic> json) {
    return PdfResourceDto(
      id: json['id'] as String,
      name: json['name'] as String,
      pdfPath: json['pdfPath'] as String,
    );
  }
}
