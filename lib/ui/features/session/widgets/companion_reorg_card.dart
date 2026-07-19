import 'package:flutter/material.dart';
import 'package:rangers_mobile/ui/features/session/view_models/post_game_state.dart';

class CompanionCard extends StatelessWidget {
  final CompanionWithType companion;
  final bool isReleased;
  final ThemeData theme;
  final VoidCallback onToggle;

  const CompanionCard({
    super.key,
    required this.companion,
    required this.isReleased,
    required this.theme,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isReleased ? theme.colorScheme.surfaceContainerHighest : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isReleased ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.secondaryContainer,
              child: Text('${companion.progressionPoints}', style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isReleased ? theme.colorScheme.onSurfaceVariant : null,
              )),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(companion.name, style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isReleased ? theme.colorScheme.onSurfaceVariant : null,
                    decoration: isReleased ? TextDecoration.lineThrough : null,
                  )),
                  Text('${companion.typeName} — ${companion.rpCost} RP',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
                ],
              ),
            ),
            Text('${companion.rpCost} RP', style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isReleased ? theme.colorScheme.error : theme.colorScheme.secondary,
            )),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                isReleased ? Icons.undo : Icons.person_remove,
                color: isReleased ? theme.colorScheme.secondary : theme.colorScheme.error,
              ),
              onPressed: onToggle,
              tooltip: isReleased ? 'Keep in company' : 'Release to reserve',
            ),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
