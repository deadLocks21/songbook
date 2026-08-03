import 'package:songbook/core/application/dtos/song_list.dto.dart';
import 'package:songbook/core/domain/model/song_schedule.dart';

/// Dit, pour chaque chant, quand il a déjà été pris et quand il est déjà prévu.
///
/// Travaille sur les listes déjà chargées pour l'UI plutôt que sur la base :
/// ce sont les mêmes, elles arrivent avec leurs entrées, et l'historique se
/// rafraîchit donc de lui-même dès qu'une liste est enregistrée ou synchronisée.
///
/// L'historique ne parle que de ce qui est sur l'appareil. Les listes des autres
/// n'y figurent pas — sauf celles reprises par abonnement, qui sont devenues des
/// listes à moi.
class SongScheduleService {
  const SongScheduleService();

  /// L'historique de chaque chant mentionné par [setlists], par identifiant de
  /// chant. Un chant qu'aucune liste ne mentionne est absent de la map.
  ///
  /// [excludingListId] écarte une liste du calcul : celle qu'on est en train
  /// d'éditer n'a rien à apprendre sur ses propres chants — sans quoi tout ce
  /// qu'elle contient déjà se présenterait comme « déjà prévu », en pointant la
  /// liste sous les yeux de l'utilisateur.
  Map<String, SongSchedule> bySongId(
    List<SongListDto> setlists, {
    required DateTime now,
    String? excludingListId,
  }) {
    final dates = <String, List<DateTime>>{};

    for (final setlist in setlists) {
      if (setlist.id == excludingListId) continue;
      for (final entry in setlist.entries) {
        (dates[entry.songId] ??= <DateTime>[]).add(setlist.scheduledAt);
      }
    }

    return {
      for (final entry in dates.entries)
        entry.key: SongSchedule.from(entry.value, now: now),
    };
  }
}
