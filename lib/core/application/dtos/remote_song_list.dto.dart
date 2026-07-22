import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/upstream_link.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';

/// DTO pour parser le JSON de l'API pour une liste de chants distante,
/// et pour construire le corps des requetes d'ecriture.
class RemoteSongListDto {
  final String id;
  final String? title;
  final DateTime scheduledAt;
  final int version;
  final DateTime createdAt;
  final List<RemoteSongListEntryDto> entries;

  /// Lien amont d'une copie : la source, et la version de celle-ci au dernier
  /// tirage. `null` sur une liste originale.
  final String? sourceListId;
  final int? sourceVersion;

  const RemoteSongListDto({
    required this.id,
    required this.title,
    required this.scheduledAt,
    required this.version,
    required this.createdAt,
    required this.entries,
    this.sourceListId,
    this.sourceVersion,
  });

  factory RemoteSongListDto.fromJson(Map<String, dynamic> json) {
    return RemoteSongListDto(
      id: json['id'] as String,
      title: json['title'] as String?,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      version: json['version'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      entries: (json['entries'] as List<dynamic>? ?? const [])
          .map((e) => RemoteSongListEntryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      sourceListId: json['sourceListId'] as String?,
      sourceVersion: json['sourceVersion'] as int?,
    );
  }

  SongList toDomain() {
    return SongList(
      id: UuidValue.parse(id),
      scheduledAt: scheduledAt,
      createdAt: createdAt,
      entries: entries.map((e) => e.toDomain()).toList(),
      title: title,
      version: version,
      upstream: UpstreamLink.fromNullable(sourceListId, sourceVersion),
    );
  }

  /// Corps d'une requete d'ecriture.
  ///
  /// [baseVersion] n'est renseigne que pour une mise a jour : c'est la version
  /// sur laquelle l'edition se base, que le serveur compare a la sienne. La
  /// creation ne l'envoie pas — il n'y a encore rien a comparer.
  static Map<String, dynamic> writePayload(SongList songList, {int? baseVersion}) {
    final upstream = songList.upstream;

    return {
      'id': songList.id.value,
      'title': songList.title,
      'scheduledAt': _wallClock(songList.scheduledAt),
      if (baseVersion != null) 'baseVersion': baseVersion,
      // Redonne a chaque ecriture, jamais sous-entendu : c'est ainsi qu'un
      // tirage fait avancer `sourceVersion`. Les deux champs partent ensemble,
      // le serveur refuse un demi-lien.
      'sourceListId': upstream?.sourceListId.value,
      'sourceVersion': upstream?.sourceVersion,
      'entries': songList.entries
          .map(
            (e) => {
              'id': e.id.value,
              'songId': e.songId.value,
              'position': e.position,
              'savedSemitones': e.savedSemitones,
            },
          )
          .toList(),
    };
  }

  /// Envoie la date telle qu'elle s'affiche, étiquetée explicitement en UTC.
  ///
  /// `scheduledAt` est une heure « au mur » : un culte à 10h reste à 10h sur
  /// tous les appareils, et l'app n'applique jamais de conversion de fuseau à
  /// l'affichage. Une date locale sérialisée par `toIso8601String()` part sans
  /// décalage (`…T10:00:00.000`) et serait donc interprétée dans le fuseau du
  /// serveur : l'heure affichée dépendrait de la configuration de celui-ci. En
  /// figeant l'étiquette ici, l'aller-retour rend toujours la même heure.
  static String _wallClock(DateTime dateTime) {
    return DateTime.utc(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
    ).toIso8601String();
  }
}

/// DTO pour une entree de liste distante.
class RemoteSongListEntryDto {
  final String id;
  final String songId;
  final int position;
  final int? savedSemitones;

  const RemoteSongListEntryDto({
    required this.id,
    required this.songId,
    required this.position,
    required this.savedSemitones,
  });

  factory RemoteSongListEntryDto.fromJson(Map<String, dynamic> json) {
    return RemoteSongListEntryDto(
      id: json['id'] as String,
      songId: json['songId'] as String,
      position: json['position'] as int,
      savedSemitones: json['savedSemitones'] as int?,
    );
  }

  SongListEntry toDomain() {
    return SongListEntry(
      id: UuidValue.parse(id),
      songId: UuidValue.parse(songId),
      position: position,
      savedSemitones: savedSemitones,
    );
  }
}
