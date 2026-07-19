import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rangers_mobile/domain/constants/base_stats.dart';
import 'package:rangers_mobile/domain/constants/heroic_abilities.dart';
import 'package:rangers_mobile/domain/constants/spells.dart';
import 'package:rangers_mobile/domain/constants/skills.dart';
import 'package:rangers_mobile/domain/constants/basic_equipment.dart';
import 'package:rangers_mobile/ui/core/widgets/stat_display.dart';
import 'package:rangers_mobile/ui/features/rangers/view_models/ranger_creation_provider.dart';

class RangerCreationStep4Review extends ConsumerWidget {
  const RangerCreationStep4Review({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rangerCreationProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ranger Name Header
          _RangerHeader(state: state),
          const SizedBox(height: 24),

          // Stats Section
          const _SectionTitle(title: 'Stats'),
          const SizedBox(height: 8),
          _StatsReview(state: state),
          const SizedBox(height: 24),

          // Abilities & Spells
          if (state.selectedHeroicAbilities.isNotEmpty ||
              state.selectedSpells.isNotEmpty) ...[
            const _SectionTitle(title: 'Abilities & Spells'),
            const SizedBox(height: 8),
            _AbilitiesReview(state: state),
            const SizedBox(height: 24),
          ],

          // Skills
          if (state.skillBonuses.isNotEmpty) ...[
            const _SectionTitle(title: 'Skills'),
            const SizedBox(height: 8),
            _SkillsReview(state: state),
            const SizedBox(height: 24),
          ],

          // Equipment
          if (state.selectedEquipment.isNotEmpty) ...[
            const _SectionTitle(title: 'Starting Equipment'),
            const SizedBox(height: 8),
            _EquipmentReview(state: state),
            const SizedBox(height: 24),
          ],

          // Recruitment Points
          const _SectionTitle(title: 'Recruitment Points'),
          const SizedBox(height: 8),
          _RecruitmentPointsReview(state: state),
          const SizedBox(height: 24),

          // Build Points Summary
          _BuildPointsSummary(state: state),
        ],
      ),
    );
  }
}

class _RangerHeader extends StatelessWidget {
  const _RangerHeader({required this.state});

  final RangerCreationState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.person,
              size: 32,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                if (state.notes.isNotEmpty)
                  Text(
                    state.notes,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer
                          .withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _StatsReview extends StatelessWidget {
  const _StatsReview({required this.state});

  final RangerCreationState state;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        StatDisplay(
          label: 'Move',
          baseValue: rangerBaseStats.move,
          effectiveValue: state.getEffectiveStat('move', rangerBaseStats.move),
        ),
        StatDisplay(
          label: 'Fight',
          baseValue: rangerBaseStats.fight,
          effectiveValue: state.getEffectiveStat('fight', rangerBaseStats.fight),
        ),
        StatDisplay(
          label: 'Shoot',
          baseValue: rangerBaseStats.shoot,
          effectiveValue:
              state.getEffectiveStat('shoot', rangerBaseStats.shoot),
        ),
        StatDisplay(
          label: 'Armour',
          baseValue: rangerBaseStats.armour,
          effectiveValue:
              state.getEffectiveStat('armour', rangerBaseStats.armour),
        ),
        StatDisplay(
          label: 'Will',
          baseValue: rangerBaseStats.will,
          effectiveValue: state.getEffectiveStat('will', rangerBaseStats.will),
        ),
        StatDisplay(
          label: 'Health',
          baseValue: rangerBaseStats.health,
          effectiveValue:
              state.getEffectiveStat('health', rangerBaseStats.health),
        ),
      ],
    );
  }
}

class _AbilitiesReview extends StatelessWidget {
  const _AbilitiesReview({required this.state});

  final RangerCreationState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.selectedHeroicAbilities.isNotEmpty) ...[
              Text(
                'Heroic Abilities',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: state.selectedHeroicAbilities.map((key) {
                  final ability = heroicAbilities.firstWhere(
                    (a) => a.key == key,
                    orElse: () => heroicAbilities.first,
                  );
                  return Chip(
                    label: Text(ability.name),
                    backgroundColor: theme.colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],
            if (state.selectedSpells.isNotEmpty) ...[
              Text(
                'Spells',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: state.selectedSpells.entries.expand((entry) {
                  final spell = spells.firstWhere(
                    (s) => s.key == entry.key,
                    orElse: () => spells.first,
                  );
                  return List.generate(entry.value, (_) => Chip(
                    label: Text(spell.name),
                    backgroundColor: theme.colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ));
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SkillsReview extends StatelessWidget {
  const _SkillsReview({required this.state});

  final RangerCreationState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 12,
          runSpacing: 8,
          children: state.skillBonuses.entries.map((entry) {
            final skill = skills.firstWhere(
              (s) => s.key == entry.key,
              orElse: () => skills.first,
            );
            return Chip(
              label: Text('${skill.name} +${entry.value}'),
              backgroundColor: theme.colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _EquipmentReview extends StatelessWidget {
  const _EquipmentReview({required this.state});

  final RangerCreationState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: state.selectedEquipment.map((key) {
            final item = getBasicEquipment(key);
            if (item == null) return const SizedBox.shrink();

            return Chip(
              label: Text(item.name),
              backgroundColor: theme.colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _RecruitmentPointsReview extends StatelessWidget {
  const _RecruitmentPointsReview({required this.state});

  final RangerCreationState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  '$startingBaseRecruitmentPoints',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Base RP',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
            if (state.recruitmentPointsBonus > 0) ...[
              Icon(
                Icons.add,
                color: theme.colorScheme.primary,
              ),
              Column(
                children: [
                  Text(
                    '+${state.recruitmentPointsBonus}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    'Bonus',
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ],
            Icon(
              Icons.arrow_forward,
              color: theme.colorScheme.primary,
            ),
            Column(
              children: [
                Text(
                  '${state.totalRecruitmentPoints}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                Text(
                  'Total RP',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BuildPointsSummary extends StatelessWidget {
  const _BuildPointsSummary({required this.state});

  final RangerCreationState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Build Points Spent',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BPStat(label: 'Stats', value: state.statPointsSpent),
              _BPStat(label: 'Abilities', value: state.abilityPointsSpent),
              _BPStat(label: 'Skills', value: state.skillPointsSpent),
              _BPStat(label: 'RP', value: state.rpPointsSpent),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Spent',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${state.totalSpent} / ${state.totalBuildPoints}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: state.remainingBuildPoints == 0
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BPStat extends StatelessWidget {
  const _BPStat({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          '$value',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall,
        ),
      ],
    );
  }
}
