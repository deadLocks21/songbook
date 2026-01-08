import 'package:songbook/core/domain/model/uuid_value.dart';

/// Représente un song tel que reçu du serveur distant.
/// Distinct de Song car contient des URLs au lieu de chemins locaux.
class RemoteSong {
  final UuidValue id;
  final String code;
  final String name;
  final DateTime updatedAt;
  final List<RemoteResource> resources;

  RemoteSong({
    required this.id,
    required this.code,
    required this.name,
    required this.updatedAt,
    required this.resources,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RemoteSong && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Classe abstraite scellée pour représenter une ressource distante.
/// Chaque ressource a un UUID unique et un nom.
sealed class RemoteResource {
  const RemoteResource();

  UuidValue get id;
  String get name;
}

/// Ressource distante contenant des URLs d'images.
class RemoteImageResource extends RemoteResource {
  @override
  final UuidValue id;
  @override
  final String name;
  final List<String> imageUrls;

  RemoteImageResource({
    required this.id,
    required this.name,
    required this.imageUrls,
  }) : assert(imageUrls.isNotEmpty, 'imageUrls cannot be empty');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RemoteImageResource &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Ressource distante contenant une URL de PDF.
class RemotePdfResource extends RemoteResource {
  @override
  final UuidValue id;
  @override
  final String name;
  final String pdfUrl;

  RemotePdfResource({
    required this.id,
    required this.name,
    required this.pdfUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RemotePdfResource &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
