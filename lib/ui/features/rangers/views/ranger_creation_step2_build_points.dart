import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/constants/base_stats.dart';
import '../../../../domain/constants/heroic_abilities.dart';
import '../../../../domain/constants/spells.dart';
import '../../../../domain/constants/skills.dart';
import '../view_models/ranger_creation_provider.dart';

class RangerCreationStep2BuildPoints extends ConsumerWidget {
  const RangerCreationStep2BuildPoints({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rangerCreationProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Build Points Header
          _BuildPointsHeader(
            remaining: state.remainingBuildPoints,
            total: state.totalBuildPoints,
          ),
          const SizedBox(height: 24),

          // Stats Section
          _SectionHeader(
            title: 'Stats',
            subtitle: 'Up to 3 BP (once per stat)',
            spent: state.statPointsSpent,
            maxSpend: state.effectiveMaxStats,
          ),
          const SizedBox(height: 8),
          _StatsSection(state: state),
          const SizedBox(height: 24),

          // Heroic Abilities Section
          _SectionHeader(
            title: 'Heroic Abilities & Spells',
            subtitle: '1 BP each, up to 5 BP total',
            spent: state.abilityPointsSpent,
            maxSpend: state.effectiveMaxAbilities,
          ),
          const SizedBox(height: 8),
          _AbilitiesSection(state: state),
          const SizedBox(height: 24),

          // Skills Section
          _SectionHeader(
            title: 'Skills',
            subtitle: '1 BP = +1 to 8 skills, up to 5 BP',
            spent: state.skillPointsSpent,
            maxSpend: state.effectiveMaxSkills,
          ),
          const SizedBox(height: 8),
          _SkillsSection(state: state),
          const SizedBox(height: 24),

          // Recruitment Points Section
          _SectionHeader(
            title: 'Recruitment Points',
            subtitle: '+10 RP per BP, up to 3 BP',
            spent: state.rpPointsSpent,
            maxSpend: state.effectiveMaxRP,
          ),
          const SizedBox(height: 8),
          _RecruitmentPointsSection(state: state),
        ],
      ),
    );
  }
}

class _BuildPointsHeader extends StatelessWidget {
  const _BuildPointsHeader({
    required this.remaining,
    required this.total,
  });

  final int remaining;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: remaining > 0
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(
                '$remaining',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: remaining > 0
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                'Build Points Remaining',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: remaining > 0
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(width: 32),
          Column(
            children: [
              Text(
                '$total',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer
                ),
              ),
              Text(
                'Total Build Points',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.spent,
    required this.maxSpend,
  });

  final String title;
  final String subtitle;
  final int spent;
  final int maxSpend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: spent >= maxSpend
                ? theme.colorScheme.errorContainer
                : theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$spent/$maxSpend',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: spent >= maxSpend
                  ? theme.colorScheme.onErrorContainer
                  : theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsSection extends ConsumerWidget {
  const _StatsSection({required this.state});

  final RangerCreationState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stats = ['move', 'fight', 'shoot', 'will', 'health'];
    final statNames = ['Move', 'Fight', 'Shoot', 'Will', 'Health'];
    final baseStats = [
      rangerBaseStats.move,
      rangerBaseStats.fight,
      rangerBaseStats.shoot,
      rangerBaseStats.will,
      rangerBaseStats.health,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: List.generate(stats.length, (index) {
            final stat = stats[index];
            final name = statNames[index];
            final base = baseStats[index];
            final bonus = state.statBonuses[stat] ?? 0;
            final canToggle = stat != 'armour'; // Can't increase armour
            final isIncreased = bonus > 0;

            return ListTile(
              title: Text(name),
              subtitle: Text('Base: $base'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isIncreased ? '+${base + bonus}' : '+$base',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isIncreased ? theme.colorScheme.primary : null,
                    ),
                  ),
                  if (canToggle) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        isIncreased
                            ? Icons.remove_circle
                            : Icons.add_circle_outline,
                        color: isIncreased
                            ? theme.colorScheme.primary
                            : (state.canSpendOnStats
                                ? theme.colorScheme.onSurfaceVariant
                                : theme.colorScheme.surfaceContainerHighest),
                      ),
                      onPressed: canToggle && (isIncreased || state.canSpendOnStats)
                          ? () {
                              ref
                                  .read(rangerCreationProvider.notifier)
                                  .toggleStatBonus(stat);
                            }
                          : null,
                    ),
                  ],
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _AbilitiesSection extends ConsumerStatefulWidget {
  const _AbilitiesSection({required this.state});

  final RangerCreationState state;

  @override
  ConsumerState<_AbilitiesSection> createState() => _AbilitiesSectionState();
}

class _AbilitiesSectionState extends ConsumerState<_AbilitiesSection> {
  final Set<String> _expandedKeys = {};

  void _toggleExpanded(String key) {
    setState(() {
      if (_expandedKeys.contains(key)) {
        _expandedKeys.remove(key);
      } else {
        _expandedKeys.add(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = widget.state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heroic Abilities
        Text(
          'Heroic Abilities',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: heroicAbilities.map((ability) {
              final isSelected =
                  state.selectedHeroicAbilities.contains(ability.key);
              final canSelect = state.canSpendOnAbilities || isSelected;
              final isExpanded = _expandedKeys.contains(ability.key);

              return Column(
                children: [
                  if (ability != heroicAbilities.first)
                    const Divider(height: 1),
                  InkWell(
                    onTap: canSelect
                        ? () => _toggleExpanded(ability.key)
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        crossAxisAlignment: isExpanded
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ability.name,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ability.description,
                                  maxLines: isExpanded ? null : 2,
                                  overflow: isExpanded
                                      ? null
                                      : TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Checkbox(
                            value: isSelected,
                            onChanged: canSelect
                                ? (value) {
                                    ref
                                        .read(rangerCreationProvider.notifier)
                                        .toggleHeroicAbility(ability.key);
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Spells
        Text(
          'Spells',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: spells.map((spell) {
              final count = state.selectedSpells[spell.key] ?? 0;
              final isSelected = count > 0;
              final canSelect = state.canSpendOnAbilities || isSelected;
              final isExpanded = _expandedKeys.contains(spell.key);

              return Column(
                children: [
                  if (spell != spells.first)
                    const Divider(height: 1),
                  InkWell(
                    onTap: canSelect
                        ? () => _toggleExpanded(spell.key)
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        crossAxisAlignment: isExpanded
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  spell.name,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  spell.description,
                                  maxLines: isExpanded ? null : 2,
                                  overflow: isExpanded
                                      ? null
                                      : TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${count}x',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(
                                  Icons.remove,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.surfaceContainerHighest,
                                ),
                                onPressed: isSelected
                                    ? () {
                                        ref
                                            .read(rangerCreationProvider.notifier)
                                            .removeSpell(spell.key);
                                      }
                                    : null,
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.add,
                                  color: state.canSpendOnAbilities
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.surfaceContainerHighest,
                                ),
                                onPressed: state.canSpendOnAbilities
                                    ? () {
                                        ref
                                            .read(rangerCreationProvider.notifier)
                                            .addSpell(spell.key);
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SkillsSection extends ConsumerWidget {
  const _SkillsSection({required this.state});

  final RangerCreationState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      child: Column(
        children: skills.map((skill) {
          final currentValue = state.skillBonuses[skill.key] ?? 0;

          return ListTile(
            title: Text(skill.name),
            subtitle: Text(
              skill.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.remove,
                    color: currentValue > 0
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                  ),
                  onPressed: currentValue > 0
                      ? () {
                          ref
                              .read(rangerCreationProvider.notifier)
                              .updateSkillBonus(skill.key, -1);
                        }
                      : null,
                ),
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Text(
                    currentValue > 0 ? '+$currentValue' : '+0',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: currentValue > 0
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add,
                    color: state.canSpendOnSkills && currentValue < state.effectiveMaxSkills
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                  ),
                  onPressed: state.canSpendOnSkills && currentValue < state.effectiveMaxSkills
                      ? () {
                          ref
                              .read(rangerCreationProvider.notifier)
                              .updateSkillBonus(skill.key, 1);
                        }
                      : null,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RecruitmentPointsSection extends ConsumerWidget {
  const _RecruitmentPointsSection({required this.state});

  final RangerCreationState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Base Recruitment Points',
                        style: theme.textTheme.labelMedium,
                      ),
                      Text(
                        '${startingBaseRecruitmentPoints}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.add,
                  color: theme.colorScheme.primary,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonus RP',
                        style: theme.textTheme.labelMedium,
                      ),
                      Text(
                        '+${state.recruitmentPointsBonus}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  color: theme.colorScheme.primary,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total RP',
                        style: theme.textTheme.labelMedium,
                      ),
                      Text(
                        '${state.totalRecruitmentPoints}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: state.recruitmentPointsBonus > 0
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                  ),
                  onPressed: state.recruitmentPointsBonus > 0
                      ? () {
                          ref
                              .read(rangerCreationProvider.notifier)
                              .removeRecruitmentPoint();
                        }
                      : null,
                ),
                const SizedBox(width: 16),
                FilledButton.tonal(
                  onPressed: state.canSpendOnRP
                      ? () {
                          ref
                              .read(rangerCreationProvider.notifier)
                              .toggleRecruitmentPoints();
                        }
                      : null,
                  child: const Text('+10 RP (1 BP)'),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: theme.colorScheme.surfaceContainerHighest,
                  ),
                  onPressed: null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
