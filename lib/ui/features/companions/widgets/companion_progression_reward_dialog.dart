import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rangers_mobile/domain/constants/companion_progression.dart';
import 'package:rangers_mobile/domain/constants/heroic_abilities.dart';
import 'package:rangers_mobile/domain/constants/skills.dart';
import 'package:rangers_mobile/ui/features/companions/view_models/companion_provider.dart';

class CompanionProgressionRewardDialog extends ConsumerStatefulWidget {
  const CompanionProgressionRewardDialog({
    required this.rangerId,
    required this.companionId,
    required this.newPp,
    required this.unclaimedRewards,
    required this.companion,
    super.key,
  });

  final int rangerId;
  final int companionId;
  final int newPp;
  final List<ProgressionReward> unclaimedRewards;
  final CompanionData companion;

  static Future<void> show(
    BuildContext context, {
    required int rangerId,
    required int companionId,
    required int newPp,
    required List<ProgressionReward> unclaimedRewards,
    required CompanionData companion,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CompanionProgressionRewardDialog(
        rangerId: rangerId,
        companionId: companionId,
        newPp: newPp,
        unclaimedRewards: unclaimedRewards,
        companion: companion,
      ),
    );
  }

  @override
  ConsumerState<CompanionProgressionRewardDialog> createState() =>
      _CompanionProgressionRewardDialogState();
}

class _CompanionProgressionRewardDialogState
    extends ConsumerState<CompanionProgressionRewardDialog> {
  int _currentIndex = 0;
  bool _applying = false;
  late CompanionData _companion;

  String? _selectedSkillKey;
  String? _selectedFightOrShoot;
  String? _selectedAbilityKey;

  @override
  void initState() {
    super.initState();
    _companion = widget.companion;
  }

  ProgressionReward get _currentReward =>
      widget.unclaimedRewards[_currentIndex];

  int get _total => widget.unclaimedRewards.length;

  bool get _canApply {
    return switch (_currentReward.rewardType) {
      'health' || 'will' => true,
      'fight_or_shoot' => _selectedFightOrShoot != null,
      'skill' => _selectedSkillKey != null,
      'heroic_ability' => _selectedAbilityKey != null,
      _ => false,
    };
  }

  Future<void> _apply() async {
    if (_applying || !_canApply) return;
    setState(() => _applying = true);

    final notifier = ref.read(companionProvider(widget.companionId).notifier);
    final reward = _currentReward;

    try {
      switch (reward.rewardType) {
        case 'health':
          await notifier.addBonusHealth(1);
          break;
        case 'will':
          final currentValue = _companion.customSkills['will'] ?? 0;
          await notifier.updateCustomSkill('will', currentValue + 2);
          break;
        case 'fight_or_shoot':
          if (_selectedFightOrShoot != null) {
            final currentValue =
                _companion.customSkills[_selectedFightOrShoot!] ?? 0;
            await notifier.updateCustomSkill(
                _selectedFightOrShoot!, currentValue + 1);
          }
          break;
        case 'skill':
          if (_selectedSkillKey != null) {
            final currentValue =
                _companion.customSkills[_selectedSkillKey!] ?? 0;
            await notifier.updateCustomSkill(
                _selectedSkillKey!, currentValue + 4);
          }
          break;
        case 'heroic_ability':
          if (_selectedAbilityKey != null) {
            await notifier.updateHeroicAbilityKeys([
              ..._companion.heroicAbilityKeys,
              _selectedAbilityKey!,
            ]);
          }
          break;
      }

      await notifier.markProgressionRewardClaimed(
        reward.threshold.toString(),
      );

      final nextIndex = _currentIndex + 1;
      if (nextIndex >= _total) {
        await notifier.setProgressionPoints(widget.newPp);
        if (mounted) Navigator.pop(context);
      } else {
        setState(() {
          _currentIndex = nextIndex;
          _selectedFightOrShoot = null;
          _selectedSkillKey = null;
          _selectedAbilityKey = null;
          _applying = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _applying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reward = _currentReward;

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
                      'Progression Reward',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (_total > 1)
                    Text(
                      '${_currentIndex + 1} of $_total',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'At ${reward.threshold} PP — ${reward.description}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (_total > 1) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) / _total,
                    minHeight: 4,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              _buildRewardContent(reward, theme),
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
                  label: Text(_buttonLabel()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buttonLabel() {
    if (_applying) return 'Applying...';
    final total = _total;
    final current = _currentIndex;
    if (total <= 1) return 'Claim Reward';
    return current == total - 1 ? 'Claim & Finish' : 'Claim & Next';
  }

  Widget _buildRewardContent(ProgressionReward reward, ThemeData theme) {
    return switch (reward.rewardType) {
      'health' => _buildAutoReward(
          'Gain +1 Health (bonus health: ${_companion.bonusHealth} → ${_companion.bonusHealth + 1})',
          theme,
        ),
      'will' => _buildAutoReward(
          'Gain +2 Will (current: ${_companion.customSkills['will'] ?? 0} → ${(_companion.customSkills['will'] ?? 0) + 2})',
          theme,
        ),
      'fight_or_shoot' => _buildFightOrShootSelector(theme),
      'skill' => _buildSkillSelector(theme),
      'heroic_ability' => _buildHeroicAbilitySelector(theme),
      _ => Text('Unknown reward type: ${reward.rewardType}'),
    };
  }

  Widget _buildAutoReward(String message, ThemeData theme) {
    return Row(
      children: [
        Icon(Icons.check_circle, color: statusGreen(theme), size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildFightOrShootSelector(ThemeData theme) {
    final choices = _currentReward.choices ?? ['fight', 'shoot'];

    return RadioGroup<String>(
      groupValue: _selectedFightOrShoot,
      onChanged: (v) {
        if (v != null) setState(() => _selectedFightOrShoot = v);
      },
      child: Column(
        children: choices.map((choice) {
          final isSelected = _selectedFightOrShoot == choice;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: isSelected
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                : null,
            child: InkWell(
              onTap: () => setState(() {
                _selectedFightOrShoot =
                    choice == _selectedFightOrShoot ? null : choice;
              }),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Radio<String>(
                      value: choice,
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      choice == 'fight'
                          ? Icons.sports_martial_arts
                          : Icons.archive,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        choice == 'fight' ? '+1 Fight' : '+1 Shoot',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
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

  Widget _buildSkillSelector(ThemeData theme) {
    return Column(
      children: skills.map((skill) {
        final baseValue = _companion.type?.baseSkills[skill.key] ?? 0;
        final customValue = _companion.customSkills[skill.key] ?? 0;
        final currentValue = baseValue + customValue;
        final isSelected = _selectedSkillKey == skill.key;
        final wouldExceedMax = currentValue + 4 > 10;

        return Card(
          margin: const EdgeInsets.only(bottom: 4),
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : null,
          child: InkWell(
            onTap: wouldExceedMax
                ? null
                : () => setState(() => _selectedSkillKey = skill.key),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(skill.name,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(
                          wouldExceedMax
                              ? 'Already at +$currentValue (max +10)'
                              : skill.description,
                          style: theme.textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      currentValue > 0 ? '+$currentValue' : '+0',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.check_circle,
                        color: theme.colorScheme.primary),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHeroicAbilitySelector(ThemeData theme) {
    final knownKeys = _companion.heroicAbilityKeys.toSet();
    final available =
        heroicAbilities.where((a) => !knownKeys.contains(a.key)).toList();

    if (available.isEmpty) {
      return Text('All heroic abilities already learned.',
          style: theme.textTheme.bodyMedium);
    }

    return RadioGroup<String>(
      groupValue: _selectedAbilityKey,
      onChanged: (v) {
        if (v != null) setState(() => _selectedAbilityKey = v);
      },
      child: Column(
        children: available.map((ability) {
          final isSelected = _selectedAbilityKey == ability.key;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: isSelected
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                : null,
            child: InkWell(
              onTap: () => setState(() {
                _selectedAbilityKey =
                    ability.key == _selectedAbilityKey ? null : ability.key;
              }),
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
                        Text(ability.description,
                            style: theme.textTheme.bodySmall),
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

Color statusGreen(ThemeData theme) =>
    theme.brightness == Brightness.dark
        ? Colors.green.shade300
        : Colors.green.shade800;
