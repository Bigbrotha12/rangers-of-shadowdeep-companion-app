import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rangers_mobile/domain/constants/creatures.dart' show getCreature;
import 'package:rangers_mobile/ui/core/theme/app_colors.dart';
import 'package:rangers_mobile/ui/core/widgets/hp_delta_control.dart';
import 'package:rangers_mobile/ui/features/session/view_models/session_provider.dart';
import 'package:rangers_mobile/ui/features/session/widgets/session_models.dart';

class CreatureCard extends ConsumerStatefulWidget {
  const CreatureCard({required this.creature, super.key});

  final CreatureData creature;

  @override
  ConsumerState<CreatureCard> createState() => _CreatureCardState();
}

class _CreatureCardState extends ConsumerState<CreatureCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final creature = widget.creature;
    final definition = creature.creatureKey != null ? getCreature(creature.creatureKey!) : null;

    final stats = definition != null
        ? StatRow(
            move: definition.move,
            fight: definition.fight,
            shoot: definition.shoot,
            armour: definition.armour,
            will: definition.will,
            health: definition.health,
          )
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: creature.isDead
          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: creature.isDead ? null : () => setState(() => _isExpanded = !_isExpanded),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wideEnough = constraints.maxWidth >= 480;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header row ──
                  Row(
                    children: [
                      // Avatar (tappable to reference detail if from bestiary)
                      GestureDetector(
                        onTap: definition != null
                            ? () => context.push('/reference/creatures/${definition.key}')
                            : null,
                        child: CircleAvatar(
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
                            if (definition != null && !creature.isDead) ...[
                              const SizedBox(height: 2),
                              Text(
                                'XP ${definition.xpValue}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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

                      // Stats table (inline when wide enough)
                      if (stats != null && wideEnough && !creature.isDead) ...[
                        const SizedBox(width: 8),
                        StatTable(stats: stats),
                        const SizedBox(width: 8),
                      ],

                      // HP Controls
                      if (!creature.isDead) ...[
                        HpDeltaControl(
                          delta: 1,
                          onDecrement: (d) => ref.read(activeSessionProvider.notifier).updateCreatureHealth(creature.id, -d),
                          onIncrement: (d) => ref.read(activeSessionProvider.notifier).updateCreatureHealth(creature.id, d),
                        ),
                        IconButton(
                          icon: AnimatedRotation(
                            turns: _isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(Icons.expand_more),
                          ),
                          onPressed: () => setState(() => _isExpanded = !_isExpanded),
                        ),
                      ],
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                        onPressed: () => ref.read(activeSessionProvider.notifier).removeCreature(creature.id),
                        tooltip: 'Remove',
                      ),
                    ],
                  ),

                  // ── Stats row (narrow screens) ──
                  if (stats != null && !creature.isDead && !wideEnough) ...[
                    const SizedBox(height: 8),
                    StatTable(stats: stats),
                  ],

                  // ── Expanded details ──
                  if (_isExpanded && !creature.isDead) ...[
                    // Notes
                    if (definition != null && definition.notes.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Notes',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, size: 18, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  definition.notes,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // Special rules
                    if (definition != null && definition.specialRules.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Special Rules',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...definition.specialRules.map((rule) => Card(
                            margin: const EdgeInsets.only(bottom: 4),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.error_outline, size: 18, color: theme.colorScheme.error),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      rule,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ],

                    // Link to reference
                    if (definition != null) ...[
                      const SizedBox(height: 12),
                      Card(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => context.push('/reference/creatures/${definition.key}'),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              children: [
                                Icon(Icons.menu_book, size: 18, color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'View in Reference',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Icon(Icons.chevron_right, size: 18, color: theme.colorScheme.onSurfaceVariant),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              );
            },
          ),
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
