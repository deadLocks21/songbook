import 'package:songbook/core/application/dtos/resource.dto.dart';
import 'package:songbook/core/application/dtos/song.dto.dart';

/// Builder pour l'objet [SongDto] afin de simplifier sa création dans les tests.
class SongBuilder {
  String _id = '00000000-0000-4000-a000-000000000001';
  String _code = 'C001';
  String _name = 'Default Song Name';
  DateTime _updatedAt = DateTime(2024, 1, 1);
  List<ResourceDto> _resources = [];

  /// Définit l'ID du chant.
  SongBuilder withId(String id) {
    _id = id;
    return this;
  }

  /// Définit le code du chant.
  SongBuilder withCode(String code) {
    _code = code;
    return this;
  }

  /// Définit le nom du chant.
  SongBuilder withName(String name) {
    _name = name;
    return this;
  }

  /// Définit la date de mise à jour.
  SongBuilder withUpdatedAt(DateTime updatedAt) {
    _updatedAt = updatedAt;
    return this;
  }

  /// Définit la liste complète des ressources.
  SongBuilder withResources(List<ResourceDto> resources) {
    _resources = resources;
    return this;
  }

  /// Ajoute une ressource spécifique à la liste.
  SongBuilder withResource(ResourceDto resource) {
    _resources.add(resource);
    return this;
  }

  /// Ajoute une ressource de type Image avec des URLs optionnelles.
  SongBuilder withImageResource({
    String? id,
    String? name,
    List<String>? imageUrls,
  }) {
    _resources.add(
      ImageResourceDto(
        id: id ?? '00000000-0000-4000-a000-00000000000${_resources.length + 1}',
        name: name ?? 'Image Resource ${_resources.length + 1}',
        imageUrls:
            imageUrls ??
            ['https://example.com/image${_resources.length + 1}.jpg'],
      ),
    );
    return this;
  }

  /// Ajoute une ressource de type PDF avec une URL optionnelle.
  SongBuilder withPdfResource({String? id, String? name, String? pdfUrl}) {
    _resources.add(
      PdfResourceDto(
        id: id ?? '00000000-0000-4000-a000-00000000000${_resources.length + 1}',
        name: name ?? 'PDF Resource ${_resources.length + 1}',
        pdfUrl:
            pdfUrl ?? 'https://example.com/document${_resources.length + 1}.pdf',
      ),
    );
    return this;
  }

  /// Vide la liste des ressources.
  SongBuilder withoutResources() {
    _resources = [];
    return this;
  }

  /// Construit et retourne l'objet [SongDto] final.
  SongDto build() {
    return SongDto(
      id: _id,
      code: _code,
      name: _name,
      updatedAt: _updatedAt,
      resources: _resources,
    );
  }
}

/// Builder pour l'objet [ImageResourceDto] afin de simplifier sa création dans les tests.
class ImageResourceDtoBuilder {
  String _id = '00000000-0000-4000-a000-000000000001';
  String _name = 'Default Image Resource';
  List<String> _imageUrls = ['https://example.com/image.jpg'];

  /// Définit l'ID de la ressource.
  ImageResourceDtoBuilder withId(String id) {
    _id = id;
    return this;
  }

  /// Définit le nom de la ressource.
  ImageResourceDtoBuilder withName(String name) {
    _name = name;
    return this;
  }

  /// Définit la liste des URLs d'images.
  ImageResourceDtoBuilder withImageUrls(List<String> imageUrls) {
    _imageUrls = imageUrls;
    return this;
  }

  /// Ajoute une URL d'image à la liste existante.
  ImageResourceDtoBuilder withImageUrl(String imageUrl) {
    _imageUrls.add(imageUrl);
    return this;
  }

  /// Construit et retourne l'objet [ImageResourceDto] final.
  ImageResourceDto build() {
    return ImageResourceDto(id: _id, name: _name, imageUrls: _imageUrls);
  }
}

/// Builder pour l'objet [PdfResourceDto] afin de simplifier sa création dans les tests.
class PdfResourceDtoBuilder {
  String _id = '00000000-0000-4000-a000-000000000001';
  String _name = 'Default PDF Resource';
  String _pdfUrl = 'https://example.com/document.pdf';

  /// Définit l'ID de la ressource.
  PdfResourceDtoBuilder withId(String id) {
    _id = id;
    return this;
  }

  /// Définit le nom de la ressource.
  PdfResourceDtoBuilder withName(String name) {
    _name = name;
    return this;
  }

  /// Définit l'URL du fichier PDF.
  PdfResourceDtoBuilder withPdfUrl(String pdfUrl) {
    _pdfUrl = pdfUrl;
    return this;
  }

  /// Construit et retourne l'objet [PdfResourceDto] final.
  PdfResourceDto build() {
    return PdfResourceDto(id: _id, name: _name, pdfUrl: _pdfUrl);
  }
}
