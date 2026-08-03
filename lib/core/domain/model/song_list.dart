import 'package:songbook/core/domain/model/upstream_link.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';

/// Entite metier representant une liste de chants.
/// Chaque liste a un UUID unique, une date/heure prevue,
/// une date de creation et une liste ordonnee d'entrees.
class SongList {
  final UuidValue id;
  final DateTime scheduledAt;
  final DateTime createdAt;
  final List<SongListEntry> entries;

  /// Titre libre, gere par le serveur mais pas encore expose dans l'UI. Conserve
  /// et renvoye tel quel pour qu'un aller-retour de synchro ne l'efface pas.
  final String? title;

  /// Version connue du canon serveur. `null` signifie « jamais poussee » : la
  /// liste n'existe pour l'instant que sur cet appareil. Toute ecriture serveur
  /// annonce cette version, et le serveur la refuse si elle est perimee.
  final int? version;

  /// Renseigne quand cette liste est la copie de celle de quelqu'un d'autre.
  /// La copie reste une liste ordinaire : librement modifiable, synchronisee
  /// comme les autres, et elle survit a la disparition de sa source.
  final UpstreamLink? upstream;

  SongList({
    required this.id,
    required this.scheduledAt,
    required this.createdAt,
    required this.entries,
    this.title,
    this.version,
    this.upstream,
  });

  /// Cette liste suit-elle encore une source ?
  bool get isFollowing => upstream != null;

  SongList copyWith({
    UuidValue? id,
    DateTime? scheduledAt,
    DateTime? createdAt,
    List<SongListEntry>? entries,
    String? title,
    int? version,
    UpstreamLink? upstream,
  }) {
    return SongList(
      id: id ?? this.id,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      createdAt: createdAt ?? this.createdAt,
      entries: entries ?? this.entries,
      title: title ?? this.title,
      version: version ?? this.version,
      upstream: upstream ?? this.upstream,
    );
  }

  /// Duplique [source] en une liste a moi, qui la suit.
  ///
  /// Tout est re-identifie : la liste, et chacune de ses entrees. Cote serveur
  /// ces identifiants sont uniques et rattaches a un proprietaire, donc les
  /// reprendre ferait entrer ma copie en collision avec l'originale.
  ///
  /// La copie part sans `version` : elle n'existe encore que sur cet appareil,
  /// son premier push sera une creation.
  static SongList copyOf(SongList source, {DateTime? now}) {
    final version = source.version;
    if (version == null) {
      throw ArgumentError(
        'Impossible de suivre une liste que le serveur ne connait pas.',
      );
    }

    return SongList(
      id: UuidValue.generate(),
      scheduledAt: source.scheduledAt,
      createdAt: now ?? DateTime.now(),
      entries: source.entries
          .map((entry) => entry.copyWith(id: UuidValue.generate()))
          .toList(),
      title: source.title,
      upstream: UpstreamLink(sourceListId: source.id, sourceVersion: version),
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

  /// Transposition enregistree pour ce chant dans cette liste, en demi-tons.
  /// `null` signifie « aucune tonalite enregistree » : le chant s'affiche a sa
  /// tonalite d'origine.
  final int? savedSemitones;

  SongListEntry({
    required this.id,
    required this.songId,
    required this.position,
    this.savedSemitones,
  });

  SongListEntry copyWith({
    UuidValue? id,
    UuidValue? songId,
    int? position,
    int? savedSemitones,
  }) {
    return SongListEntry(
      id: id ?? this.id,
      songId: songId ?? this.songId,
      position: position ?? this.position,
      savedSemitones: savedSemitones ?? this.savedSemitones,
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
