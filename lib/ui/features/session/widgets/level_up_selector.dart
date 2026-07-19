import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/domain/constants/experience_table.dart';
import 'package:rangers_mobile/domain/constants/heroic_abilities.dart';
import 'package:rangers_mobile/domain/constants/skills.dart';
import 'package:rangers_mobile/ui/core/theme/app_colors.dart';
import 'package:rangers_mobile/ui/features/session/view_models/post_game_provider.dart';
import 'package:rangers_mobile/ui/features/session/view_models/post_game_state.dart';

class LevelUpBonusSelector extends ConsumerStatefulWidget {
  final PostGameState postGame;
  final ThemeData theme;

  const LevelUpBonusSelector({super.key, required this.postGame, required this.theme});

  @override
  ConsumerState<LevelUpBonusSelector> createState() => _LevelUpBonusSelectorState();
}

class _LevelUpBonusSelectorState extends ConsumerState<LevelUpBonusSelector> {
  @override
  Widget build(BuildContext context) {
    final postGame = widget.postGame;
    final theme = widget.theme;
    final bonus = postGame.bonusType!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Level-Up Bonus: ${_bonusTitle(bonus)}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            switch (bonus) {
              LevelBonusType.improveSkills => _buildSkillsSelector(postGame, theme),
              LevelBonusType.improveStats => _buildStatsSelector(postGame, theme),
              LevelBonusType.gainRecruitmentPoints => _buildRpBonus(postGame, theme),
              LevelBonusType.newHeroicAbilityOrSpell => _buildAbilitySelector(postGame, theme),
            },
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _canApply(postGame) ? () {
                  ref.read(postGameProvider.notifier).applyLevelUp();
                } : null,
                icon: const Icon(Icons.check),
                label: const Text('Apply Level-Up Bonus'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _bonusTitle(LevelBonusType type) {
    switch (type) {
      case LevelBonusType.improveSkills: return 'Improve Skills (+5 total, max +2 per skill)';
      case LevelBonusType.improveStats: return 'Improve Stats (choose one stat)';
      case LevelBonusType.gainRecruitmentPoints: return 'Gain Recruitment Points';
      case LevelBonusType.newHeroicAbilityOrSpell: return 'New Heroic Ability or Spell';
    }
  }

  bool _canApply(PostGameState state) {
    switch (state.bonusType!) {
      case LevelBonusType.improveSkills: return state.remainingSkillPoints == 0;
      case LevelBonusType.improveStats: return state.selectedStat != null;
      case LevelBonusType.gainRecruitmentPoints: return true;
      case LevelBonusType.newHeroicAbilityOrSpell: return state.selectedHeroicAbility != null;
    }
  }

  Widget _buildSkillsSelector(PostGameState state, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Remaining: ', style: theme.textTheme.bodyMedium),
            Text('${state.remainingSkillPoints}', style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: state.remainingSkillPoints > 0 ? theme.colorScheme.primary : statusGreen(theme),
            )),
          ],
        ),
        const SizedBox(height: 8),
        ...skills.map((skill) {
          final currentValue = state.rangerSkills.where((s) => s.skillKey == skill.key).firstOrNull?.value ?? 0;
          final allocated = state.skillAllocations[skill.key] ?? 0;
          final newValue = currentValue + allocated;
          final canAdd = allocated < 2 && state.remainingSkillPoints > 0;
          final canRemove = allocated > 0;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(skill.name, style: theme.textTheme.bodySmall),
                ),
                const SizedBox(width: 8),
                Text('$currentValue', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(width: 4),
                if (allocated > 0)
                  Text('+$allocated', style: theme.textTheme.bodySmall?.copyWith(color: statusGreen(theme), fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  iconSize: 20,
                  onPressed: canRemove ? () {
                    ref.read(postGameProvider.notifier).setSkillAllocation(skill.key, -1);
                  } : null,
                  visualDensity: VisualDensity.compact,
                ),
                Text('$newValue', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  iconSize: 20,
                  onPressed: canAdd ? () {
                    ref.read(postGameProvider.notifier).setSkillAllocation(skill.key, 1);
                  } : null,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatsSelector(PostGameState state, ThemeData theme) {
    const statLabels = {
      'move': 'Move', 'fight': 'Fight', 'shoot': 'Shoot', 'will': 'Will', 'health': 'Health',
    };
    return RadioGroup<String>(
      groupValue: state.selectedStat,
      onChanged: (v) {
        if (v != null) ref.read(postGameProvider.notifier).selectStat(v);
      },
      child: Column(
        children: statImprovementLimits.map((limit) {
          final stat = limit.stat;
          final maxVal = limit.maxValue;
          final currentVal = _getStatValue(state.ranger, stat);
          final atMax = currentVal >= maxVal;
          return Opacity(
            opacity: atMax ? 0.5 : 1.0,
            child: AbsorbPointer(
              absorbing: atMax,
              child: RadioListTile<String>(
                title: Text(statLabels[stat] ?? stat),
                subtitle: Text('$currentVal / $maxVal${atMax ? ' (MAX)' : ''}'),
                value: stat,
                dense: true,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  int _getStatValue(Ranger? ranger, String stat) {
    if (ranger == null) return 0;
    switch (stat) {
      case 'move': return ranger.move;
      case 'fight': return ranger.fight;
      case 'shoot': return ranger.shoot;
      case 'will': return ranger.will;
      case 'health': return ranger.health;
      default: return 0;
    }
  }

  Widget _buildRpBonus(PostGameState state, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Base Recruitment Points: ', style: theme.textTheme.bodyMedium),
            Text('${state.availableRp}', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text('Gain +10 Recruitment Points (usable after this mission).',
          style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
      ],
    );
  }

  Widget _buildAbilitySelector(PostGameState state, ThemeData theme) {
    final knownKeys = state.rangerAbilities.map((a) => a.abilityKey).toSet();
    final available = heroicAbilities.where((a) => !knownKeys.contains(a.key)).toList();

    if (available.isEmpty) {
      return Text('All heroic abilities already learned.', style: theme.textTheme.bodyMedium);
    }

    return RadioGroup<String>(
      groupValue: state.selectedHeroicAbility,
      onChanged: (v) {
        if (v != null) ref.read(postGameProvider.notifier).selectHeroicAbility(v);
      },
      child: Column(
        children: available.map((ability) {
          final isSelected = state.selectedHeroicAbility == ability.key;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: isSelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) : null,
            child: InkWell(
              onTap: () => ref.read(postGameProvider.notifier).selectHeroicAbility(ability.key),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Radio<String>(
                      value: ability.key,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ability.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(ability.description, style: theme.textTheme.bodySmall),
                          if (isSelected) ...[
                            const SizedBox(height: 4),
                            Text('Use: ${ability.whenToUse}', style: theme.textTheme.labelSmall?.copyWith(fontStyle: FontStyle.italic, color: theme.colorScheme.primary)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
