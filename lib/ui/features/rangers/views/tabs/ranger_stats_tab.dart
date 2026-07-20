import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/data/repositories/ranger_repository_provider.dart';
import 'package:rangers_mobile/domain/constants/experience_table.dart';
import 'package:rangers_mobile/data/services/post_game_service.dart';
import 'package:rangers_mobile/ui/core/theme/spacing.dart';
import 'package:rangers_mobile/ui/core/widgets/stat_display.dart';
import 'package:rangers_mobile/ui/features/rangers/view_models/ranger_detail_provider.dart';
import 'package:rangers_mobile/ui/features/rangers/widgets/ranger_level_up_dialog.dart';

class RangerStatsTab extends ConsumerWidget {
  const RangerStatsTab({
    required this.ranger,
    required this.statModifiers,
    this.onEditNotes,
    super.key,
  });

  final RangerDetail ranger;
  final Map<String, int> statModifiers;
  final VoidCallback? onEditNotes;

  static const _levelBonusLabels = {
    LevelBonusType.improveSkills: '+5 Skill Points',
    LevelBonusType.improveStats: '+1 Stat',
    LevelBonusType.gainRecruitmentPoints: '+10 Recruitment Points',
    LevelBonusType.newHeroicAbilityOrSpell: 'New Heroic Ability or Spell',
  };

  String _labelForBonus(LevelBonusType type) =>
      _levelBonusLabels[type] ?? 'Unknown';

  List<({int level, LevelBonusType bonusType})> _computeLevelRewards(int currentLevel) {
    final rewards = <({int level, LevelBonusType bonusType})>[];
    for (int lvl = 1; lvl <= currentLevel; lvl++) {
      rewards.add((level: lvl, bonusType: getLevelBonusType(lvl)));
    }
    return rewards;
  }

  Future<void> _showEditXpDialog(BuildContext context, WidgetRef ref) async {
    final rangerData = ranger.ranger;
    final controller = TextEditingController();

    final addedXp = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add XP'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current level: ${rangerData.level} | Current XP: ${rangerData.experiencePoints}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'XP to Add',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Level will be recalculated automatically.\n'
              'You will be guided to apply level-up bonuses.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text.trim());
              if (value != null && value > 0) {
                Navigator.pop(context, value);
              }
            },
            child: Text(
              'Add XP',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              )
            ),
          ),
        ],
      ),
    );

    if (addedXp != null) {
      final newXp = (rangerData.experiencePoints + addedXp).clamp(0, maxExperiencePoints);
      final oldLevel = rangerData.level;
      final newLevel = calculateLevel(newXp);
      final repo = ref.read(rangerRepositoryProvider);

      if (newLevel > oldLevel) {
        if (context.mounted) {
          await RangerLevelUpDialog.show(
            context,
            rangerId: rangerData.id,
            newXp: newXp,
            oldLevel: oldLevel,
            newLevel: newLevel,
          );
        }
      } else {
        await repo.updateRangerFields(rangerData.id, RangersCompanion(
          experiencePoints: Value(newXp),
          level: Value(newLevel),
        ));
      }

      ref.invalidate(rangerDetailProvider(rangerData.id));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final r = ranger.ranger;

    int effective(String key, int base) {
      final mod = statModifiers[key];
      return mod != null ? base + mod : base;
    }

    final xpToNext = getXpCostForLevel(r.level);
    final nextBonusType = getLevelBonusType(r.level + 1);
    final levelRewards = _computeLevelRewards(r.level);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stats',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Spacing.md),
          Center(
            child: Wrap(
              spacing: Spacing.lg,
              runSpacing: Spacing.md,
              alignment: WrapAlignment.center,
              children: [
                StatDisplay(label: 'Move', baseValue: r.move, effectiveValue: effective('move', r.move)),
                StatDisplay(label: 'Fight', baseValue: r.fight, effectiveValue: effective('fight', r.fight)),
                StatDisplay(label: 'Shoot', baseValue: r.shoot, effectiveValue: effective('shoot', r.shoot)),
                StatDisplay(label: 'Armour', baseValue: r.armour, effectiveValue: effective('armour', r.armour)),
                StatDisplay(label: 'Will', baseValue: r.will, effectiveValue: effective('will', r.will)),
                StatDisplay(
                  label: 'Health',
                  baseValue: r.health,
                  effectiveValue: r.currentHealth,
                ),
                StatDisplay(
                  label: 'Damage',
                  baseValue: statModifiers['damage'] ?? 0,
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),
          Row(
            children: [
              Text(
                'XP & Level',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () => _showEditXpDialog(context, ref),
                tooltip: 'Add XP',
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          SizedBox(
            width: double.infinity,
            child: Container(
              padding: const EdgeInsets.all(Spacing.lg),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Level ${r.level}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    'XP: ${r.experiencePoints}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Next level at ${r.experiencePoints + xpToNext} total XP (+$xpToNext needed)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),
          SizedBox(
            width: double.infinity,
            child: Container(
              padding: const EdgeInsets.all(Spacing.lg),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_forward,
                    color: theme.colorScheme.onTertiaryContainer,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Next Reward',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onTertiaryContainer,
                          ),
                        ),
                        Text(
                          _labelForBonus(nextBonusType),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.lg),
          Text(
            'Level Rewards',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          ...levelRewards.map((reward) {
            final isCurrent = reward.level == r.level;
            final isPast = reward.level < r.level;
            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isCurrent
                    ? theme.colorScheme.primaryContainer
                    : null,
                borderRadius: BorderRadius.circular(8),
                border: isCurrent
                    ? Border.all(color: theme.colorScheme.primary)
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    isPast
                        ? Icons.check_circle
                        : Icons.radio_button_checked,
                    size: 18,
                    color: isPast
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Level ${reward.level} — ${_labelForBonus(reward.bonusType)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCurrent
                            ? theme.colorScheme.onPrimaryContainer
                            : null,
                      ),
                    ),
                  ),
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'CURRENT',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
          const SizedBox(height: Spacing.xl),
          Text(
            'Recruitment Points',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Spacing.md),
          Container(
            padding: const EdgeInsets.all(Spacing.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${r.baseRecruitmentPoints}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Text(
                  'RP',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xl),
          Row(
            children: [
              Text(
                'Notes',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  r.notes.isEmpty ? Icons.add : Icons.edit,
                  size: 20,
                ),
                onPressed: onEditNotes,
                tooltip: r.notes.isEmpty ? 'Add note' : 'Edit note',
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          if (r.notes.isNotEmpty)
            Text(
              r.notes,
              style: theme.textTheme.bodyMedium,
            )
          else
            Text(
              'No notes added.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
