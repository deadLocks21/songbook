import 'package:songbook/core/domain/model/uuid_value.dart';

/// Classe abstraite scellée pour représenter une ressource d'un chant.
/// Chaque ressource a un UUID unique et un nom.
sealed class Resource {
  const Resource();

  UuidValue get id;
  String get name;
}

/// Ressource contenant des images.
/// Les URLs pointent vers les images distantes ; les fichiers sont
/// téléchargés et mis en cache à la demande lors de l'affichage.
class ImageResource extends Resource {
  @override
  final UuidValue id;
  @override
  final String name;
  final List<String> imageUrls;

  ImageResource({
    required this.id,
    required this.name,
    required this.imageUrls,
  }) : assert(imageUrls.isNotEmpty, 'imageUrls cannot be empty');

  ImageResource copyWith({
    UuidValue? id,
    String? name,
    List<String>? imageUrls,
  }) {
    return ImageResource(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrls: imageUrls ?? this.imageUrls,
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
/// L'URL pointe vers le PDF distant ; le fichier est téléchargé et mis en
/// cache à la demande.
class PdfResource extends Resource {
  @override
  final UuidValue id;
  @override
  final String name;
  final String pdfUrl;

  PdfResource({required this.id, required this.name, required this.pdfUrl});

  PdfResource copyWith({UuidValue? id, String? name, String? pdfUrl}) {
    return PdfResource(
      id: id ?? this.id,
      name: name ?? this.name,
      pdfUrl: pdfUrl ?? this.pdfUrl,
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

/// Ressource contenant un fichier ChordPro (accords + paroles).
/// L'URL pointe vers le fichier texte distant ; il est téléchargé et mis en
/// cache à la demande, comme les partitions images/PDF.
class ChordProResource extends Resource {
  @override
  final UuidValue id;
  @override
  final String name;
  final String chordProUrl;

  ChordProResource({
    required this.id,
    required this.name,
    required this.chordProUrl,
  });

  ChordProResource copyWith({UuidValue? id, String? name, String? chordProUrl}) {
    return ChordProResource(
      id: id ?? this.id,
      name: name ?? this.name,
      chordProUrl: chordProUrl ?? this.chordProUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChordProResource &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
