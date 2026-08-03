import 'package:flutter/material.dart';
import 'package:songbook/core/domain/model/song_schedule.dart';
import 'package:songbook/ui/utils/date_format.dart';

/// Déroule toutes les dates auxquelles un chant a été pris, et celles où il est
/// déjà prévu.
///
/// Ailleurs l'app ne donne qu'un signal compact — « chanté il y a trois
/// semaines » — parce qu'il s'agit de trancher vite. Ici on vient exprès pour
/// l'historique : les dates sont donc données en entier.
Future<void> showSongHistorySheet(
  BuildContext context, {
  required String songName,
  required SongSchedule schedule,
  DateTime? now,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) =>
        SongHistorySheet(songName: songName, schedule: schedule, now: now),
  );
}

/// Contenu du panneau d'historique. Séparé de [showSongHistorySheet] pour être
/// montable seul en test.
class SongHistorySheet extends StatelessWidget {
  final String songName;
  final SongSchedule schedule;

  /// Repère du « il y a … ». Injectable pour que les tests ne dépendent pas de
  /// l'horloge.
  final DateTime? now;

  const SongHistorySheet({
    super.key,
    required this.songName,
    required this.schedule,
    this.now,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reference = now ?? DateTime.now();
    final muted = theme.colorScheme.onSurfaceVariant;

    return ConstrainedBox(
      key: const Key('songHistorySheet'),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      ),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
        children: [
          Text('Historique', style: theme.textTheme.titleLarge),
          Text(
            songName,
            style: theme.textTheme.bodyMedium?.copyWith(color: muted),
          ),
          const SizedBox(height: 16.0),
          if (schedule.isEmpty)
            Text(
              key: const Key('songHistoryEmpty'),
              "Ce chant n'a encore jamais été pris.",
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
            ),
          if (schedule.upcoming.isNotEmpty) ...[
            _SectionTitle('Déjà prévu', color: theme.colorScheme.primary),
            for (final date in schedule.upcoming) _DateRow(date: date),
            const SizedBox(height: 16.0),
          ],
          if (schedule.past.isNotEmpty) ...[
            _SectionTitle('Déjà chanté', color: muted),
            for (final date in schedule.past)
              _DateRow(
                date: date,
                trailing: formatRelativePast(date, now: reference),
              ),
          ],
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  final Color color;

  const _SectionTitle(this.label, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color),
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final DateTime date;

  /// Distance dans le temps (« il y a 3 semaines »), pour les dates passées
  /// seulement : une date à venir se lit telle quelle.
  final String? trailing;

  const _DateRow({required this.date, this.trailing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Text(formatDate(date), style: theme.textTheme.bodyMedium),
          ),
          if (trailing != null)
            Text(
              trailing!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
