import 'package:songbook/core/domain/model/resource.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';

/// Entité métier représentant un chant.
/// Chaque chant a un UUID unique, un code unique, un nom et une liste de ressources.
class Song {
  final UuidValue id;
  final String code;
  final String name;
  final List<Resource> resources;

  Song({
    required this.id,
    required this.code,
    required this.name,
    required this.resources,
  }) : assert(code.trim().isNotEmpty, 'code cannot be empty'),
       assert(name.trim().isNotEmpty, 'name cannot be empty');

  Song copyWith({
    UuidValue? id,
    String? code,
    String? name,
    List<Resource>? resources,
  }) {
    return Song(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      resources: resources ?? this.resources,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
