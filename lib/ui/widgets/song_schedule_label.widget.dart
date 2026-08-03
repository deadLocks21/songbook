import 'package:flutter/material.dart';
import 'package:songbook/core/domain/model/song_schedule.dart';
import 'package:songbook/ui/utils/date_format.dart';

/// Ligne compacte disant depuis quand un chant n'a pas été pris.
///
/// Un seul signal à la fois, le plus décisif : « déjà prévu » l'emporte sur
/// « déjà chanté », qui l'emporte sur « jamais chanté ». Il s'agit de trancher
/// d'un coup d'œil au moment de composer une liste ; l'historique complet est
/// sur la page du chant.
class SongScheduleLabel extends StatelessWidget {
  final SongSchedule schedule;

  /// Repère du « il y a … ». Injectable pour que les tests ne dépendent pas de
  /// l'horloge.
  final DateTime? now;

  const SongScheduleLabel({super.key, required this.schedule, this.now});

  /// En deçà de quoi un chant est « récent » — celui qu'on hésite à reprendre,
  /// et qui mérite donc d'être signalé plutôt que dit du bout des lèvres.
  static const recent = Duration(days: 28);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reference = now ?? DateTime.now();
    final signal = _signal(theme, reference);
    final repeats = _repeats(reference);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(signal.icon, size: 14.0, color: signal.color),
        const SizedBox(width: 4.0),
        Flexible(
          child: Text(
            repeats == null ? signal.text : '${signal.text} · $repeats',
            style: theme.textTheme.bodySmall?.copyWith(color: signal.color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// « 3 fois en 3 mois », ou `null` quand il n'y a rien à ajouter.
  ///
  /// N'apparaît qu'à partir de deux reprises : une seule, la dernière date l'a
  /// déjà dit, et l'afficher sur chaque chant noierait ceux qui reviennent
  /// vraiment souvent — les seuls que cette ligne cherche à faire ressortir.
  String? _repeats(DateTime reference) {
    final count = schedule.recentCount(reference);
    if (count < 2) return null;
    return '$count fois en ${SongSchedule.recentMonths} mois';
  }

  ({IconData icon, String text, Color color}) _signal(
    ThemeData theme,
    DateTime reference,
  ) {
    final muted = theme.colorScheme.onSurfaceVariant;
    final next = schedule.nextPlannedAt;
    final last = schedule.lastSungAt;

    if (next != null) {
      return (
        icon: Icons.event_available,
        text: 'Déjà prévu ${formatShortDate(next, now: reference)}',
        color: theme.colorScheme.primary,
      );
    }

    if (last != null) {
      return (
        icon: Icons.history,
        text: 'Chanté ${formatRelativePast(last, now: reference)}',
        color: reference.difference(last) < recent
            ? theme.colorScheme.tertiary
            : muted,
      );
    }

    return (
      icon: Icons.history_toggle_off,
      text: 'Jamais chanté',
      color: muted,
    );
  }
}
