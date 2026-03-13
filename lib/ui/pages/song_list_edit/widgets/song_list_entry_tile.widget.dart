import 'package:flutter/material.dart';
import 'package:songbook/core/application/dtos/song_list.dto.dart';

/// Card representant une entree dans la liste reordonnnable.
class SongListEntryTile extends StatelessWidget {
  final SongListEntryDto entry;
  final int index;
  final int totalCount;
  final VoidCallback onRemove;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  const SongListEntryTile({
    super.key,
    required this.entry,
    required this.index,
    required this.totalCount,
    required this.onRemove,
    this.onMoveUp,
    this.onMoveDown,
  });

  bool get _isFirst => index == 0;
  bool get _isLast => index == totalCount - 1;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDesktop = MediaQuery.sizeOf(context).width >= 600;

    return ReorderableDragStartListener(
      index: index,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: Row(
              children: [
                Icon(
                  Icons.drag_indicator,
                  color: colorScheme.onSurfaceVariant.withAlpha(120),
                  size: 20,
                ),
                const SizedBox(width: 12),
                _NumberBadge(
                  number: index + 1,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        entry.songName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        entry.songCode,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isDesktop) ...[
                  _ArrowButton(
                    icon: Icons.arrow_upward,
                    onPressed: _isFirst ? null : onMoveUp,
                    colorScheme: colorScheme,
                  ),
                  _ArrowButton(
                    icon: Icons.arrow_downward,
                    onPressed: _isLast ? null : onMoveDown,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(width: 8),
                ],
                _RemoveButton(
                  onPressed: onRemove,
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  final int number;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _NumberBadge({
    required this.number,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.surfaceContainerHighest,
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final ColorScheme colorScheme;

  const _ArrowButton({
    required this.icon,
    required this.onPressed,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 18),
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      color: colorScheme.onSurfaceVariant,
      disabledColor: colorScheme.onSurfaceVariant.withAlpha(60),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  final VoidCallback onPressed;
  final ColorScheme colorScheme;

  const _RemoveButton({
    required this.onPressed,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.close, size: 18),
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      color: colorScheme.onSurfaceVariant,
    );
  }
}
