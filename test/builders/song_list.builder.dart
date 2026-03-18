import 'package:songbook/core/application/dtos/song_list.dto.dart';

/// Builder pour l'objet [SongListDto] afin de simplifier sa création dans les tests.
class SongListBuilder {
  String _id = '00000000-0000-4000-a000-000000000001';
  DateTime _scheduledAt = DateTime(2025, 3, 16, 10, 0);
  DateTime _createdAt = DateTime(2025, 3, 10);
  List<SongListEntryDto> _entries = [];

  /// Définit l'ID de la liste.
  SongListBuilder withId(String id) {
    _id = id;
    return this;
  }

  /// Définit la date planifiée.
  SongListBuilder withScheduledAt(DateTime scheduledAt) {
    _scheduledAt = scheduledAt;
    return this;
  }

  /// Définit la date de création.
  SongListBuilder withCreatedAt(DateTime createdAt) {
    _createdAt = createdAt;
    return this;
  }

  /// Définit la liste des entrées.
  SongListBuilder withEntries(List<SongListEntryDto> entries) {
    _entries = entries;
    return this;
  }

  /// Ajoute une entrée à la liste.
  SongListBuilder withEntry(SongListEntryDto entry) {
    _entries.add(entry);
    return this;
  }

  /// Ajoute une entrée simplifiée à la liste.
  SongListBuilder withSongEntry({
    String? id,
    required String songId,
    String? songCode,
    String? songName,
  }) {
    final position = _entries.length;
    _entries.add(
      SongListEntryDto(
        id: id ?? '00000000-0000-4000-b000-00000000000${_entries.length + 1}',
        songId: songId,
        position: position,
        songCode: songCode ?? 'C${(position + 1).toString().padLeft(3, '0')}',
        songName: songName ?? 'Song ${position + 1}',
      ),
    );
    return this;
  }

  /// Construit et retourne l'objet [SongListDto] final.
  SongListDto build() {
    return SongListDto(
      id: _id,
      scheduledAt: _scheduledAt,
      createdAt: _createdAt,
      entries: _entries,
    );
  }
}

/// Builder pour l'objet [SongListEntryDto].
class SongListEntryBuilder {
  String _id = '00000000-0000-4000-b000-000000000001';
  String _songId = '00000000-0000-4000-a000-000000000001';
  int _position = 0;
  String _songCode = 'C001';
  String _songName = 'Default Song';

  SongListEntryBuilder withId(String id) {
    _id = id;
    return this;
  }

  SongListEntryBuilder withSongId(String songId) {
    _songId = songId;
    return this;
  }

  SongListEntryBuilder withPosition(int position) {
    _position = position;
    return this;
  }

  SongListEntryBuilder withSongCode(String songCode) {
    _songCode = songCode;
    return this;
  }

  SongListEntryBuilder withSongName(String songName) {
    _songName = songName;
    return this;
  }

  SongListEntryDto build() {
    return SongListEntryDto(
      id: _id,
      songId: _songId,
      position: _position,
      songCode: _songCode,
      songName: _songName,
    );
  }
}
