import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/constants/companion_progression.dart';
import '../../../../domain/constants/skills.dart';
import '../../../../domain/constants/heroic_abilities.dart';
import '../view_models/companion_provider.dart';

class CompanionProgressionView extends ConsumerWidget {
  const CompanionProgressionView({
    required this.rangerId,
    required this.companionId,
    super.key,
  });

  final int rangerId;
  final int companionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companion = ref.watch(companionProvider(companionId));
    final theme = Theme.of(context);

    if (companion == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Progression')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentPP = companion.progressionPoints;
    final claimedThresholds = Set<int>.from(
      companion.claimedProgressionRewards.map(int.parse),
    );
    final nextReward = getNextProgressionReward(currentPP, claimedThresholds);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progression'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProgressionHeader(
              companionName: companion.customName,
              currentPP: currentPP,
              nextReward: nextReward,
            ),
            const SizedBox(height: 24),
            Text(
              'Progression Rewards',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _ProgressionTimeline(
              currentPP: currentPP,
              claimedThresholds: claimedThresholds,
            ),
            const SizedBox(height: 24),
            if (nextReward != null) ...[
              Text(
                'Next Reward Available',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              _RewardCard(
                reward: nextReward,
                isAvailable: true,
                onTap: () {
                  _showApplyRewardDialog(context, ref, companion, nextReward);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showApplyRewardDialog(
    BuildContext context,
    WidgetRef ref,
    CompanionData companion,
    ProgressionReward reward,
  ) {
    switch (reward.rewardType) {
      case 'fight_or_shoot':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(reward.description),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: reward.choices!.map((choice) {
                return ListTile(
                  title: Text(choice == 'fight' ? '+1 Fight' : '+1 Shoot'),
                  leading: Icon(choice == 'fight' ? Icons.sports_martial_arts : Icons.archive),
                  onTap: () async {
                    await _applyReward(ref, companion, reward, choice);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
        break;
      case 'skill':
        _showSkillSelector(context, ref, companion, reward);
        break;
      case 'heroic_ability':
        _showHeroicAbilitySelector(context, ref, companion, reward);
        break;
      case 'health':
      case 'will':
        _applyReward(ref, companion, reward, null);
        break;
    }
  }

  void _showSkillSelector(
    BuildContext context,
    WidgetRef ref,
    CompanionData companion,
    ProgressionReward reward,
  ) {
    String? selectedSkillKey;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(reward.description),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: skills.length,
              itemBuilder: (context, index) {
                final skill = skills[index];
                final type = companion.type;
                final baseValue = type?.baseSkills[skill.key] ?? 0;
                final customValue = companion.customSkills[skill.key] ?? 0;
                final currentValue = baseValue + customValue;
                final isSelected = selectedSkillKey == skill.key;
                final wouldExceedMax = currentValue + 4 > 10;

                return Card(
                  margin: const EdgeInsets.only(bottom: 4),
                  color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                  child: ListTile(
                    onTap: wouldExceedMax ? null : () {
                      setDialogState(() => selectedSkillKey = skill.key);
                    },
                    title: Text(skill.name),
                    subtitle: Text(
                      wouldExceedMax
                          ? 'Already at +$currentValue (max +10)'
                          : skill.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            currentValue > 0 ? '+$currentValue' : '+0',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: selectedSkillKey != null
                  ? () async {
                      await _applySkillReward(ref, companion, reward, selectedSkillKey!);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  : null,
              child: const Text('Select'),
            ),
          ],
        ),
      ),
    );
  }

  void _showHeroicAbilitySelector(
    BuildContext context,
    WidgetRef ref,
    CompanionData companion,
    ProgressionReward reward,
  ) {
    String? selectedAbilityKey;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(reward.description),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: heroicAbilities.length,
              itemBuilder: (context, index) {
                final ability = heroicAbilities[index];
                final isSelected = selectedAbilityKey == ability.key;

                return Card(
                  margin: const EdgeInsets.only(bottom: 4),
                  color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                  child: ListTile(
                    onTap: () {
                      setDialogState(() => selectedAbilityKey = ability.key);
                    },
                    title: Text(ability.name),
                    subtitle: Text(
                      ability.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: selectedAbilityKey != null
                  ? () async {
                      await _applyHeroicAbilityReward(ref, companion, reward, selectedAbilityKey!);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  : null,
              child: const Text('Select'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _applySkillReward(
    WidgetRef ref,
    CompanionData companion,
    ProgressionReward reward,
    String skillKey,
  ) async {
    final notifier = ref.read(companionProvider(companion.id).notifier);
    final currentValue = companion.customSkills[skillKey] ?? 0;
    await notifier.updateCustomSkill(skillKey, currentValue + 4);
    await notifier.markProgressionRewardClaimed(reward.threshold.toString());
  }

  Future<void> _applyHeroicAbilityReward(
    WidgetRef ref,
    CompanionData companion,
    ProgressionReward reward,
    String abilityKey,
  ) async {
    final notifier = ref.read(companionProvider(companion.id).notifier);
    // Store heroic ability in customSkills with 'heroic_' prefix
    final currentAbilities = Map<String, int>.from(companion.customSkills);
    currentAbilities['heroic_$abilityKey'] = 1;
    // Persist all custom skills
    for (final entry in currentAbilities.entries) {
      await notifier.updateCustomSkill(entry.key, entry.value);
    }
    await notifier.markProgressionRewardClaimed(reward.threshold.toString());
  }

  Future<void> _applyReward(
    WidgetRef ref,
    CompanionData companion,
    ProgressionReward reward,
    String? choice,
  ) async {
    final notifier = ref.read(companionProvider(companion.id).notifier);
    
    // Apply the effect
    switch (reward.rewardType) {
      case 'health':
        await notifier.addBonusHealth(1);
        break;
      case 'fight_or_shoot':
        if (choice != null) {
          final currentValue = companion.customSkills[choice] ?? 0;
          await notifier.updateCustomSkill(choice, currentValue + 1);
        }
        break;
      case 'will':
        final currentValue = companion.customSkills['will'] ?? 0;
        await notifier.updateCustomSkill('will', currentValue + 2);
        break;
    }
    
    // Mark as claimed
    await notifier.markProgressionRewardClaimed(reward.threshold.toString());
  }
}

class _ProgressionHeader extends StatelessWidget {
  const _ProgressionHeader({
    required this.companionName,
    required this.currentPP,
    required this.nextReward,
  });

  final String companionName;
  final int currentPP;
  final ProgressionReward? nextReward;

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
        children: [
          Text(
            companionName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PPBadge(pp: currentPP),
              if (nextReward != null) ...[
                const SizedBox(width: 24),
                Icon(
                  Icons.arrow_forward,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 24),
                _NextRewardBadge(nextReward: nextReward!),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PPBadge extends StatelessWidget {
  const _PPBadge({required this.pp});

  final int pp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          '$pp',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          'Progression Points',
          style: theme.textTheme.labelMedium,
        ),
      ],
    );
  }
}

class _NextRewardBadge extends StatelessWidget {
  const _NextRewardBadge({required this.nextReward});

  final ProgressionReward nextReward;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          '${nextReward.threshold}',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.tertiary,
          ),
        ),
        Text(
          'Next Threshold',
          style: theme.textTheme.labelMedium,
        ),
      ],
    );
  }
}

class _ProgressionTimeline extends StatelessWidget {
  const _ProgressionTimeline({
    required this.currentPP,
    required this.claimedThresholds,
  });

  final int currentPP;
  final Set<int> claimedThresholds;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: progressionRewards.map((reward) {
        final isAchieved = currentPP >= reward.threshold;
        final isClaimed = claimedThresholds.contains(reward.threshold);
        final isCurrent = isAchieved && !isClaimed && currentPP < (reward.threshold + 5);

        return _TimelineItem(
          reward: reward,
          isAchieved: isAchieved,
          isClaimed: isClaimed,
          isCurrent: isCurrent,
        );
      }).toList(),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.reward,
    required this.isAchieved,
    required this.isClaimed,
    required this.isCurrent,
  });

  final ProgressionReward reward;
  final bool isAchieved;
  final bool isClaimed;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isClaimed
                    ? Colors.green
                    : isAchieved
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                border: Border.all(
                  color: isCurrent
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  width: isCurrent ? 2 : 1,
                ),
              ),
              child: isClaimed
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : isAchieved
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: theme.colorScheme.onPrimary,
                        )
                      : Center(
                          child: Text(
                            '${reward.threshold}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
            ),
            if (reward.threshold != progressionRewards.last.threshold)
              Container(
                width: 2,
                height: 40,
                color: theme.colorScheme.outline,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reward.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isAchieved ? FontWeight.bold : FontWeight.normal,
                  color: isClaimed
                      ? Colors.green
                      : isAchieved
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (isCurrent) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'NEXT',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              if (isClaimed) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'CLAIMED',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RewardCard extends StatelessWidget {
  const _RewardCard({
    required this.reward,
    required this.isAvailable,
    this.onTap,
  });

  final ProgressionReward reward;
  final bool isAvailable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: isAvailable ? theme.colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.card_giftcard,
                color: isAvailable
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'At ${reward.threshold} PP',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isAvailable
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      reward.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isAvailable
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    if (reward.choices != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Choose from: ${reward.choices!.join(', ')}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isAvailable
                              ? theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.7)
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isAvailable)
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
