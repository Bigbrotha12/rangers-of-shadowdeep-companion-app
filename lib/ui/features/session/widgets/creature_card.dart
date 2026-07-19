import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rangers_mobile/ui/core/theme/app_colors.dart';
import 'package:rangers_mobile/ui/core/widgets/hp_delta_control.dart';
import 'package:rangers_mobile/ui/features/session/view_models/session_provider.dart';


class CreatureCard extends ConsumerStatefulWidget {
  const CreatureCard({required this.creature, super.key});

  final CreatureData creature;

  @override
  ConsumerState<CreatureCard> createState() => _CreatureCardState();
}

class _CreatureCardState extends ConsumerState<CreatureCard> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final creature = widget.creature;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: creature.isDead ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5) : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Icon
            CircleAvatar(
              backgroundColor: creature.isDead
                  ? theme.colorScheme.error
                  : theme.colorScheme.errorContainer,
              child: Icon(
                creature.isDead ? Icons.close : Icons.pets,
                color: creature.isDead
                    ? theme.colorScheme.onError
                    : theme.colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(width: 12),

            // Name and HP bar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    creature.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: creature.isDead ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // HP bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: creature.maxHealth > 0 ? creature.currentHealth / creature.maxHealth : 0,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      color: creature.currentHealth <= 0
                          ? theme.colorScheme.error
                          : creature.currentHealth <= creature.maxHealth ~/ 3
                              ? statusOrange(theme)
                              : theme.colorScheme.error,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'HP: ${creature.currentHealth}/${creature.maxHealth}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            // HP Controls
            if (!creature.isDead)
              HpDeltaControl(
                delta: 1,
                onDecrement: (d) => ref.read(activeSessionProvider.notifier).updateCreatureHealth(creature.id, -d),
                onIncrement: (d) => ref.read(activeSessionProvider.notifier).updateCreatureHealth(creature.id, d),
              ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
              onPressed: () => ref.read(activeSessionProvider.notifier).removeCreature(creature.id),
              tooltip: 'Remove',
            ),
          ],
        ),
      ),
    );
  }
}

// ── Creature Panel ──

class CreaturePanel extends StatelessWidget {
  const CreaturePanel({required this.session, super.key});

  final ActiveSessionState session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Creatures',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${session.creatures.where((c) => !c.isDead).length} alive',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (session.creatures.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No creatures added yet',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          )
        else
          ...session.creatures.map((creature) => CreatureCard(creature: creature)),
      ],
    );
  }
}
