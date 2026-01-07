import 'package:songbook/core/domain/model/uuid_value.dart';

/// Classe abstraite scellée pour représenter une ressource d'un chant.
/// Chaque ressource a un UUID unique et un nom.
sealed class Resource {
  const Resource();

  UuidValue get id;
  String get name;
}

/// Ressource contenant des images.
/// Les chemins sont absolus vers les fichiers locaux.
class ImageResource extends Resource {
  @override
  final UuidValue id;
  @override
  final String name;
  final List<String> imagePaths;

  ImageResource({
    required this.id,
    required this.name,
    required this.imagePaths,
  }) : assert(imagePaths.isNotEmpty, 'imagePaths cannot be empty');

  ImageResource copyWith({
    UuidValue? id,
    String? name,
    List<String>? imagePaths,
  }) {
    return ImageResource(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImageResource &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Ressource contenant un fichier PDF.
/// Le chemin est absolu vers le fichier local.
class PdfResource extends Resource {
  @override
  final UuidValue id;
  @override
  final String name;
  final String pdfPath;

  PdfResource({required this.id, required this.name, required this.pdfPath});

  PdfResource copyWith({UuidValue? id, String? name, String? pdfPath}) {
    return PdfResource(
      id: id ?? this.id,
      name: name ?? this.name,
      pdfPath: pdfPath ?? this.pdfPath,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PdfResource &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
