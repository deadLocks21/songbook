import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';

/// DTO pour representer une liste de chants dans l'UI.
class SongListDto {
  final String id;
  final DateTime scheduledAt;
  final DateTime createdAt;
  final List<SongListEntryDto> entries;

  /// Cette liste est la copie de celle de quelqu'un d'autre, et suit encore sa
  /// source. L'UI s'en sert pour la distinguer.
  final bool isFollowing;

  /// La source suivie et la version qu'on en a déjà prise. L'UI les compare à
  /// l'état rapporté par la dernière synchro pour savoir s'il y a quelque chose
  /// à tirer. `null` sur une liste originale.
  ///
  /// Le DTO n'a pas à les renvoyer en écriture : l'enregistrement reprend le
  /// lien depuis la copie locale.
  final String? sourceListId;
  final int? sourceVersion;

  const SongListDto({
    required this.id,
    required this.scheduledAt,
    required this.createdAt,
    required this.entries,
    this.isFollowing = false,
    this.sourceListId,
    this.sourceVersion,
  });

  /// Cree un SongListDto depuis une entite SongList domain
  /// avec des entrees resolues (code + nom du chant).
  factory SongListDto.fromDomain(
    SongList songList,
    Map<UuidValue, ({String code, String name})> songInfo,
  ) {
    final entries = songList.entries.map((entry) {
      final info = songInfo[entry.songId];
      return SongListEntryDto(
        id: entry.id.value,
        songId: entry.songId.value,
        position: entry.position,
        savedSemitones: entry.savedSemitones,
        songCode: info?.code ?? '???',
        songName: info?.name ?? 'Chant supprimé',
      );
    }).toList()..sort((a, b) => a.position.compareTo(b.position));

    return SongListDto(
      id: songList.id.value,
      scheduledAt: songList.scheduledAt,
      createdAt: songList.createdAt,
      entries: entries,
      isFollowing: songList.isFollowing,
      sourceListId: songList.upstream?.sourceListId.value,
      sourceVersion: songList.upstream?.sourceVersion,
    );
  }

  /// Convertit ce DTO en entite SongList domain.
  SongList toDomain() {
    return SongList(
      id: UuidValue.parse(id),
      scheduledAt: scheduledAt,
      createdAt: createdAt,
      entries: entries
          .asMap()
          .entries
          .map(
            (e) => SongListEntry(
              id: UuidValue.parse(e.value.id),
              songId: UuidValue.parse(e.value.songId),
              position: e.key,
              savedSemitones: e.value.savedSemitones,
            ),
          )
          .toList(),
    );
  }
}

/// DTO pour une entree dans une liste de chants.
/// Contient les donnees resolues du chant pour l'UI.
class SongListEntryDto {
  final String id;
  final String songId;
  final int position;

  /// Transposition enregistree pour ce chant dans cette liste, en demi-tons.
  /// `null` = aucune tonalite enregistree (chant a sa tonalite d'origine).
  final int? savedSemitones;

  final String songCode;
  final String songName;

  const SongListEntryDto({
    required this.id,
    required this.songId,
    required this.position,
    this.savedSemitones,
    required this.songCode,
    required this.songName,
  });

  SongListEntryDto copyWith({
    String? id,
    String? songId,
    int? position,
    int? savedSemitones,
    String? songCode,
    String? songName,
  }) {
    return SongListEntryDto(
      id: id ?? this.id,
      songId: songId ?? this.songId,
      position: position ?? this.position,
      savedSemitones: savedSemitones ?? this.savedSemitones,
      songCode: songCode ?? this.songCode,
      songName: songName ?? this.songName,
    );
  }
}
