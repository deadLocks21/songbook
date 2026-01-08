import 'package:songbook/core/domain/model/sync_diff.dart';

/// Type d'action de synchronisation.
enum SyncActionType { add, update, delete }

/// DTO pour représenter les différences de synchronisation dans l'UI.
class SyncDiffDto {
  final int toAddCount;
  final int toUpdateCount;
  final int toDeleteCount;
  final List<SongSyncActionDto> actions;

  const SyncDiffDto({
    required this.toAddCount,
    required this.toUpdateCount,
    required this.toDeleteCount,
    required this.actions,
  });

  /// Crée un SyncDiffDto depuis un SyncDiff domain.
  factory SyncDiffDto.fromDomain(SyncDiff diff) {
    final actions = <SongSyncActionDto>[
      ...diff.toAdd.map(
        (a) => SongSyncActionDto(
          songId: a.remoteSong.id.value,
          songName: a.remoteSong.name,
          type: SyncActionType.add,
        ),
      ),
      ...diff.toUpdate.map(
        (u) => SongSyncActionDto(
          songId: u.remoteSong.id.value,
          songName: u.remoteSong.name,
          type: SyncActionType.update,
        ),
      ),
      ...diff.toDelete.map(
        (d) => SongSyncActionDto(
          songId: d.localSong.id.value,
          songName: d.localSong.name,
          type: SyncActionType.delete,
        ),
      ),
    ];

    return SyncDiffDto(
      toAddCount: diff.toAdd.length,
      toUpdateCount: diff.toUpdate.length,
      toDeleteCount: diff.toDelete.length,
      actions: actions,
    );
  }

  /// Retourne true si aucune modification n'est nécessaire.
  bool get isEmpty =>
      toAddCount == 0 && toUpdateCount == 0 && toDeleteCount == 0;

  /// Retourne le nombre total d'actions.
  int get totalActions => toAddCount + toUpdateCount + toDeleteCount;
}

/// DTO pour représenter une action de synchronisation individuelle.
class SongSyncActionDto {
  final String songId;
  final String songName;
  final SyncActionType type;

  const SongSyncActionDto({
    required this.songId,
    required this.songName,
    required this.type,
  });
}
