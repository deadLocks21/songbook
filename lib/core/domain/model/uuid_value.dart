import 'package:uuid/uuid.dart';

/// Value Object pour représenter un UUID v4.
/// Garantit que la valeur est toujours un UUID valide.
class UuidValue {
  final String value;

  const UuidValue._(this.value);

  /// Crée un nouvel UUID v4
  factory UuidValue.generate() {
    return UuidValue._(const Uuid().v4());
  }

  /// Parse un UUID depuis une String.
  /// Lance une exception si la String n'est pas un UUID valide.
  factory UuidValue.parse(String value) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );
    if (!uuidRegex.hasMatch(value)) {
      throw ArgumentError('Invalid UUID format: $value');
    }
    return UuidValue._(value);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UuidValue &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
