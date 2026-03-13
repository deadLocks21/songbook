import 'package:songbook/core/domain/model/uuid_value.dart';

/// Entite metier representant une liste de chants.
/// Chaque liste a un UUID unique, une date/heure prevue,
/// une date de creation et une liste ordonnee d'entrees.
class SongList {
  final UuidValue id;
  final DateTime scheduledAt;
  final DateTime createdAt;
  final List<SongListEntry> entries;

  SongList({
    required this.id,
    required this.scheduledAt,
    required this.createdAt,
    required this.entries,
  });

  SongList copyWith({
    UuidValue? id,
    DateTime? scheduledAt,
    DateTime? createdAt,
    List<SongListEntry>? entries,
  }) {
    return SongList(
      id: id ?? this.id,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      createdAt: createdAt ?? this.createdAt,
      entries: entries ?? this.entries,
    );
  }

  /// Calcule le prochain dimanche a 10h00.
  static DateTime nextSundayAt10() {
    final now = DateTime.now();
    final daysUntilSunday = (DateTime.sunday - now.weekday) % 7;
    final next = daysUntilSunday == 0
        ? now.add(const Duration(days: 7))
        : now.add(Duration(days: daysUntilSunday));
    return DateTime(next.year, next.month, next.day, 10, 0);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongList && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Entree dans une liste de chants.
/// Possede son propre identifiant pour permettre les doublons du meme chant.
class SongListEntry {
  final UuidValue id;
  final UuidValue songId;
  final int position;

  SongListEntry({
    required this.id,
    required this.songId,
    required this.position,
  });

  SongListEntry copyWith({UuidValue? id, UuidValue? songId, int? position}) {
    return SongListEntry(
      id: id ?? this.id,
      songId: songId ?? this.songId,
      position: position ?? this.position,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongListEntry &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
