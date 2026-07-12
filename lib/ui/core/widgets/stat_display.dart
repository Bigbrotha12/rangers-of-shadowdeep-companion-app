import 'package:flutter/material.dart';

class StatDisplay extends StatelessWidget {
  const StatDisplay({
    required this.label,
    required this.baseValue,
    this.effectiveValue,
    this.isCompact = false,
    super.key,
  });

  final String label;
  final int baseValue;
  final int? effectiveValue;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSplitStat = effectiveValue != null && effectiveValue != baseValue;

    if (isCompact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            hasSplitStat ? '$baseValue/$effectiveValue' : '$baseValue',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: hasSplitStat
                ? theme.colorScheme.errorContainer
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            hasSplitStat ? '$baseValue/$effectiveValue' : '$baseValue',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: hasSplitStat
                  ? theme.colorScheme.onErrorContainer
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
