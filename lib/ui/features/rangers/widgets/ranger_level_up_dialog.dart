import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/data/repositories/ranger_repository_provider.dart';
import 'package:rangers_mobile/domain/constants/experience_table.dart'
    show LevelBonusType, getLevelBonusType, getStatMaxValue, statImprovementLimits;
import 'package:rangers_mobile/domain/constants/heroic_abilities.dart';
import 'package:rangers_mobile/domain/constants/skills.dart';
import 'package:rangers_mobile/ui/core/theme/app_colors.dart';
import 'package:rangers_mobile/ui/features/rangers/view_models/ranger_detail_provider.dart';

class RangerLevelUpDialog extends ConsumerStatefulWidget {
  const RangerLevelUpDialog({
    required this.rangerId,
    required this.newXp,
    required this.oldLevel,
    required this.newLevel,
    super.key,
  });

  final int rangerId;
  final int newXp;
  final int oldLevel;
  final int newLevel;

  static Future<void> show(
    BuildContext context, {
    required int rangerId,
    required int newXp,
    required int oldLevel,
    required int newLevel,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => RangerLevelUpDialog(
        rangerId: rangerId,
        newXp: newXp,
        oldLevel: oldLevel,
        newLevel: newLevel,
      ),
    );
  }

  @override
  ConsumerState<RangerLevelUpDialog> createState() => _RangerLevelUpDialogState();
}

class _RangerLevelUpDialogState extends ConsumerState<RangerLevelUpDialog> {
  List<LevelBonusType>? _bonuses;
  int _currentIndex = 0;
  Ranger? _ranger;
  List<RangerSkill> _skills = [];
  List<RangerAbility> _abilities = [];
  bool _loading = true;
  bool _applying = false;

  final Map<String, int> _skillAllocations = {};
  int _remainingSkillPoints = 0;
  String? _selectedStat;
  String? _selectedHeroicAbility;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final repo = ref.read(rangerRepositoryProvider);
    final ranger = await repo.getRangerById(widget.rangerId);
    final skills = await repo.getRangerSkills(widget.rangerId);
    final abilities = await repo.getRangerAbilities(widget.rangerId);

    final bonuses = <LevelBonusType>[];
    for (int lvl = widget.oldLevel + 1; lvl <= widget.newLevel; lvl++) {
      bonuses.add(getLevelBonusType(lvl));
    }

    setState(() {
      _ranger = ranger;
      _skills = skills;
      _abilities = abilities;
      _bonuses = bonuses;
      _loading = false;
      _remainingSkillPoints =
          bonuses.isNotEmpty && bonuses[0] == LevelBonusType.improveSkills ? 5 : 0;
    });
  }

  LevelBonusType? get _currentBonus =>
      _bonuses != null && _currentIndex < _bonuses!.length ? _bonuses![_currentIndex] : null;

  bool get _canApply {
    final bonus = _currentBonus;
    if (bonus == null) return false;
    return switch (bonus) {
      LevelBonusType.improveSkills => _remainingSkillPoints == 0,
      LevelBonusType.improveStats => _selectedStat != null,
      LevelBonusType.gainRecruitmentPoints => true,
      LevelBonusType.newHeroicAbilityOrSpell => _selectedHeroicAbility != null,
    };
  }

  Future<void> _apply() async {
    final bonus = _currentBonus;
    if (_applying || bonus == null) return;
    if (!_canApply) return;
    setState(() => _applying = true);

    final repo = ref.read(rangerRepositoryProvider);
    final ranger = _ranger;

    try {
      if (bonus == LevelBonusType.gainRecruitmentPoints && ranger != null) {
        await repo.updateRangerFields(widget.rangerId, RangersCompanion(
          baseRecruitmentPoints: Value(ranger.baseRecruitmentPoints + 10),
        ));
      } else if (bonus == LevelBonusType.improveSkills) {
        for (final entry in _skillAllocations.entries) {
          final existing = _skills.where((s) => s.skillKey == entry.key).firstOrNull;
          final newValue = (existing?.value ?? 0) + entry.value;
          if (existing != null) {
            await repo.updateRangerSkill(RangerSkillsCompanion(
              id: Value(existing.id),
              rangerId: Value(existing.rangerId),
              skillKey: Value(existing.skillKey),
              value: Value(newValue),
            ));
          } else {
            await repo.insertRangerSkill(RangerSkillsCompanion(
              rangerId: Value(widget.rangerId),
              skillKey: Value(entry.key),
              value: Value(newValue),
            ));
          }
        }
      } else if (bonus == LevelBonusType.improveStats && _selectedStat != null && ranger != null) {
        final stat = _selectedStat!;
        final currentValue = _getRangerStat(ranger, stat);
        final maxValue = getStatMaxValue(stat);
        final newValue = (currentValue + 1).clamp(0, maxValue);
        await repo.updateRangerFields(widget.rangerId, RangersCompanion(
          move: stat == 'move' ? Value(newValue) : const Value.absent(),
          fight: stat == 'fight' ? Value(newValue) : const Value.absent(),
          shoot: stat == 'shoot' ? Value(newValue) : const Value.absent(),
          will: stat == 'will' ? Value(newValue) : const Value.absent(),
          health: stat == 'health' ? Value(newValue) : const Value.absent(),
        ));
      } else if (bonus == LevelBonusType.newHeroicAbilityOrSpell && _selectedHeroicAbility != null) {
        await repo.insertRangerAbility(RangerAbilitiesCompanion(
          rangerId: Value(widget.rangerId),
          abilityKey: Value(_selectedHeroicAbility!),
          abilityType: const Value('heroic_ability'),
        ));
      }

      final nextIndex = _currentIndex + 1;
      if (nextIndex >= (_bonuses?.length ?? 0)) {
        await repo.updateRangerFields(widget.rangerId, RangersCompanion(
          experiencePoints: Value(widget.newXp),
          level: Value(widget.newLevel),
        ));
        if (mounted) Navigator.pop(context);
      } else {
        final updatedRanger = await repo.getRangerById(widget.rangerId);
        final updatedSkills = await repo.getRangerSkills(widget.rangerId);
        final updatedAbilities = await repo.getRangerAbilities(widget.rangerId);
        final nextBonus = _bonuses![nextIndex];

        setState(() {
          _currentIndex = nextIndex;
          _ranger = updatedRanger ?? ranger;
          _skills = updatedSkills;
          _abilities = updatedAbilities;
          _skillAllocations.clear();
          _remainingSkillPoints = nextBonus == LevelBonusType.improveSkills ? 5 : 0;
          _selectedStat = null;
          _selectedHeroicAbility = null;
          _applying = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _applying = false);
        ref.invalidate(rangerDetailProvider(widget.rangerId));
      }
    }
  }

  int _getRangerStat(Ranger ranger, String stat) {
    return switch (stat) {
      'move' => ranger.move,
      'fight' => ranger.fight,
      'shoot' => ranger.shoot,
      'will' => ranger.will,
      'health' => ranger.health,
      _ => 0,
    };
  }

  String _bonusTitle(LevelBonusType type) {
    return switch (type) {
      LevelBonusType.improveSkills => 'Improve Skills (+5 total, max +2 per skill)',
      LevelBonusType.improveStats => 'Improve Stats (choose one stat)',
      LevelBonusType.gainRecruitmentPoints => 'Gain Recruitment Points',
      LevelBonusType.newHeroicAbilityOrSpell => 'New Heroic Ability or Spell',
    };
  }

  String _bonusLabel(LevelBonusType type) {
    return switch (type) {
      LevelBonusType.improveSkills => '+5 Skill Points',
      LevelBonusType.improveStats => '+1 Stat',
      LevelBonusType.gainRecruitmentPoints => '+10 Recruitment Points',
      LevelBonusType.newHeroicAbilityOrSpell => 'New Heroic Ability or Spell',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final bonus = _currentBonus;
    if (bonus == null) {
      return const Center(child: Text('No level-up bonuses to apply.'));
    }

    final total = _bonuses!.length;
    final index = _currentIndex;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Level-Up Bonus',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (total > 1)
                    Text(
                      '$index${_ordinalSuffix(index)} of $total',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Level ${widget.oldLevel + index + 1} — ${_bonusLabel(bonus)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (total > 1) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (index + 1) / total,
                    minHeight: 4,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                _bonusTitle(bonus),
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              switch (bonus) {
                LevelBonusType.improveSkills => _buildSkillsSelector(theme),
                LevelBonusType.improveStats => _buildStatsSelector(theme),
                LevelBonusType.gainRecruitmentPoints => _buildRpBonus(theme),
                LevelBonusType.newHeroicAbilityOrSpell => _buildAbilitySelector(theme),
              },
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: (_canApply && !_applying) ? _apply : null,
                  icon: _applying
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: Text(
                    _applying
                        ? 'Applying...'
                        : _currentIndex == (_bonuses!.length - 1)
                            ? 'Apply & Finish'
                            : 'Apply & Next',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _ordinalSuffix(int n) {
    final i = n + 1;
    if (i % 100 >= 11 && i % 100 <= 13) return 'th';
    return switch (i % 10) {
      1 => 'st',
      2 => 'nd',
      3 => 'rd',
      _ => 'th',
    };
  }

  Widget _buildSkillsSelector(ThemeData theme) {
    final ranger = _ranger;
    if (ranger == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.tune, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text('Points Remaining: ', style: theme.textTheme.bodyMedium),
            Text(
              '$_remainingSkillPoints',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _remainingSkillPoints > 0
                    ? theme.colorScheme.primary
                    : statusGreen(theme),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...skills.map((skill) {
          final currentValue = _skills.where((s) => s.skillKey == skill.key).firstOrNull?.value ?? 0;
          final allocated = _skillAllocations[skill.key] ?? 0;
          final newValue = currentValue + allocated;
          final canAdd = allocated < 2 && _remainingSkillPoints > 0;
          final canRemove = allocated > 0;
          final isModified = allocated > 0;

          void changeSkill(int delta) {
            setState(() {
              final newPoints = ((_skillAllocations[skill.key] ?? 0) + delta).clamp(0, 2);
              final actualDelta = newPoints - (_skillAllocations[skill.key] ?? 0);
              if (delta > 0 && actualDelta > 0 && _remainingSkillPoints < actualDelta) return;
              _remainingSkillPoints -= actualDelta;
              if (newPoints == 0) {
                _skillAllocations.remove(skill.key);
              } else {
                _skillAllocations[skill.key] = newPoints;
              }
            });
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isModified ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) : null,
              borderRadius: BorderRadius.circular(14),
              border: isModified
                  ? Border.all(color: theme.colorScheme.primaryContainer)
                  : Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          skill.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '$currentValue',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isModified ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface,
                              ),
                            ),
                            if (isModified) ...[
                              const SizedBox(width: 6),
                              Icon(Icons.arrow_forward, size: 14, color: theme.colorScheme.primary),
                              const SizedBox(width: 6),
                              Text(
                                '$newValue',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: statusGreen(theme),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      icon: Icon(Icons.remove, color: canRemove ? theme.colorScheme.onSurface : null),
                      iconSize: 22,
                      onPressed: canRemove ? () => changeSkill(-1) : null,
                      style: IconButton.styleFrom(
                        backgroundColor: canRemove ? theme.colorScheme.surfaceContainerHighest : null,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 40,
                    child: Center(
                      child: Text(
                        '$newValue',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isModified ? statusGreen(theme) : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      icon: Icon(Icons.add, color: canAdd ? theme.colorScheme.onPrimaryContainer : null),
                      iconSize: 22,
                      onPressed: canAdd ? () => changeSkill(1) : null,
                      style: IconButton.styleFrom(
                        backgroundColor: canAdd ? theme.colorScheme.primaryContainer : null,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatsSelector(ThemeData theme) {
    final ranger = _ranger;
    if (ranger == null) return const SizedBox.shrink();

    const statLabels = {
      'move': 'Move',
      'fight': 'Fight',
      'shoot': 'Shoot',
      'will': 'Will',
      'health': 'Health',
    };

    return RadioGroup<String>(
      groupValue: _selectedStat,
      onChanged: (v) {
        if (v != null) setState(() => _selectedStat = v == _selectedStat ? null : v);
      },
      child: Column(
        children: statImprovementLimits.map((limit) {
          final stat = limit.stat;
          final maxVal = limit.maxValue;
          final currentVal = _getRangerStat(ranger, stat);
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

  Widget _buildRpBonus(ThemeData theme) {
    final ranger = _ranger;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Base Recruitment Points: ', style: theme.textTheme.bodyMedium),
            Text(
              '${ranger?.baseRecruitmentPoints ?? 0}',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Gain +10 Recruitment Points.',
          style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildAbilitySelector(ThemeData theme) {
    final knownKeys = _abilities.map((a) => a.abilityKey).toSet();
    final available = heroicAbilities.where((a) => !knownKeys.contains(a.key)).toList();

    if (available.isEmpty) {
      return Text('All heroic abilities already learned.', style: theme.textTheme.bodyMedium);
    }

    return RadioGroup<String>(
      groupValue: _selectedHeroicAbility,
      onChanged: (v) {
        if (v != null) setState(() => _selectedHeroicAbility = v == _selectedHeroicAbility ? null : v);
      },
      child: Column(
        children: available.map((ability) {
          final isSelected = _selectedHeroicAbility == ability.key;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: isSelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3) : null,
            child: InkWell(
              onTap: () => setState(
                  () => _selectedHeroicAbility = ability.key == _selectedHeroicAbility ? null : ability.key),
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
                        Text(ability.name,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(ability.description, style: theme.textTheme.bodySmall),
                        if (isSelected) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Use: ${ability.whenToUse}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: theme.colorScheme.primary,
                            ),
                          ),
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
