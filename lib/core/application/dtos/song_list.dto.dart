import 'package:songbook/core/domain/model/song_list.dart';
import 'package:songbook/core/domain/model/uuid_value.dart';

/// DTO pour representer une liste de chants dans l'UI.
class SongListDto {
  final String id;
  final DateTime scheduledAt;
  final DateTime createdAt;
  final List<SongListEntryDto> entries;

  const SongListDto({
    required this.id,
    required this.scheduledAt,
    required this.createdAt,
    required this.entries,
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
        songCode: info?.code ?? '???',
        songName: info?.name ?? 'Chant supprimé',
      );
    }).toList()..sort((a, b) => a.position.compareTo(b.position));

    return SongListDto(
      id: songList.id.value,
      scheduledAt: songList.scheduledAt,
      createdAt: songList.createdAt,
      entries: entries,
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
  final String songCode;
  final String songName;

  const SongListEntryDto({
    required this.id,
    required this.songId,
    required this.position,
    required this.songCode,
    required this.songName,
  });

  SongListEntryDto copyWith({
    String? id,
    String? songId,
    int? position,
    String? songCode,
    String? songName,
  }) {
    return SongListEntryDto(
      id: id ?? this.id,
      songId: songId ?? this.songId,
      position: position ?? this.position,
      songCode: songCode ?? this.songCode,
      songName: songName ?? this.songName,
    );
  }
}
