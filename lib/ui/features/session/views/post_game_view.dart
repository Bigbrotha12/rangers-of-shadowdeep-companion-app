import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rangers_mobile/domain/constants/experience_table.dart';
import 'package:rangers_mobile/ui/core/theme/app_colors.dart';
import 'package:rangers_mobile/ui/features/companions/views/recruit_companions_view.dart';
import 'package:rangers_mobile/ui/features/session/view_models/post_game_provider.dart';
import 'package:rangers_mobile/ui/features/session/view_models/post_game_state.dart';
import 'package:rangers_mobile/ui/features/session/view_models/session_provider.dart';
import 'package:rangers_mobile/ui/features/session/widgets/companion_reorg_card.dart';
import 'package:rangers_mobile/ui/features/session/widgets/level_up_selector.dart';
import 'package:rangers_mobile/ui/features/session/widgets/survival_card.dart';
import 'package:rangers_mobile/ui/features/session/widgets/treasure_widgets.dart';

class PostGameView extends ConsumerStatefulWidget {
  const PostGameView({required this.sessionId, super.key});

  final int sessionId;

  @override
  ConsumerState<PostGameView> createState() => _PostGameViewState();
}

class _PostGameViewState extends ConsumerState<PostGameView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activeSession = ref.read(activeSessionProvider);
      final deadIds = activeSession.party
        .where((m) => m.type == 'companion' && m.isDead)
        .map((m) => m.id)
        .toList();

      ref.read(postGameProvider.notifier).loadFromSession(
        widget.sessionId,
        deadCompanionIds: deadIds,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final postGame = ref.watch(postGameProvider);
    final theme = Theme.of(context);

    if (postGame == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Post-Game Report')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (postGame.isFinalized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Post-Game Report')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 80, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text('Post-Game Complete!', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('All results have been saved.', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: 24),
              FilledButton(onPressed: () {
                ref.invalidate(sessionHistoryProvider);
                context.go('/session');
              }, child: const Text('Back to Sessions')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Post-Game Report')),
      body: Stepper(
        currentStep: postGame.currentStep,
        onStepContinue: postGame.currentStep < 3 ? () {
          ref.read(postGameProvider.notifier).nextStep();
        } : null,
        onStepCancel: postGame.currentStep > 0 ? () {
          ref.read(postGameProvider.notifier).goToStep(postGame.currentStep - 1);
        } : null,
        controlsBuilder: (context, details) {
          final isLast = postGame.currentStep == 3;
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                if (isLast)
                  FilledButton.icon(
                    onPressed: () => _finalize(context),
                    icon: const Icon(Icons.save),
                    label: const Text('Finalize & Save'),
                  )
                else
                  FilledButton(
                    onPressed: details.onStepContinue,
                    child: const Text('Continue'),
                  ),
                const SizedBox(width: 12),
                if (postGame.currentStep > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    child: const Text('Back'),
                  ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Injury & Death'),
            subtitle: const Text('Check who survived'),
            isActive: postGame.currentStep >= 0,
            state: _stepState(0, postGame),
            content: _buildStep1(postGame, theme),
          ),
          Step(
            title: const Text('Experience & Level'),
            subtitle: const Text('Award XP and level up'),
            isActive: postGame.currentStep >= 1,
            state: _stepState(1, postGame),
            content: _buildStep2(postGame, theme),
          ),
          Step(
            title: const Text('Treasure'),
            subtitle: const Text('Roll for treasure tokens'),
            isActive: postGame.currentStep >= 2,
            state: _stepState(2, postGame),
            content: _buildStep3(postGame, theme),
          ),
          Step(
            title: const Text('Reorganize'),
            subtitle: const Text('Manage your company'),
            isActive: postGame.currentStep >= 3,
            state: _stepState(3, postGame),
            content: _buildStep4(postGame, theme),
          ),
        ],
      ),
    );
  }

  StepState _stepState(int index, PostGameState state) {
    if (state.currentStep == index) return StepState.editing;
    if (state.currentStep > index) return StepState.complete;
    return StepState.indexed;
  }

  /* ── Step 1: Injury & Death ───────────────────────────────── */
  Widget _buildStep1(PostGameState postGame, ThemeData theme) {
    if (postGame.survivalTargets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: statusGreen(theme), size: 32),
                const SizedBox(width: 12),
                Expanded(child: Text('No heroes were reduced to 0 HP during this session.', style: theme.textTheme.bodyLarge)),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'The following heroes were reduced to 0 HP. Roll on the Survival Table for each.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Survival Table (d20)', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('1-2: Dead  3-4: Permanent Injury  5-6: Badly Wounded  7-8: Close Call  9+: Full Recovery'),
              Text('Rangers add +1 to the die roll.', style: theme.textTheme.labelSmall?.copyWith(fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        ...postGame.survivalTargets.map((target) => SurvivalCard(
          target: target,
          onRoll: () => ref.read(postGameProvider.notifier).rollSurvival(target.id, isRanger: target.isRanger),
          onManualRoll: (roll) => ref.read(postGameProvider.notifier).rollSurvival(target.id, isRanger: target.isRanger, predeterminedRoll: roll),
          onRollInjury: () => ref.read(postGameProvider.notifier).rollInjury(target.id, isRanger: target.isRanger),
          onManualInjuryRoll: (roll) => ref.read(postGameProvider.notifier).rollInjuryWithValue(target.id, roll, isRanger: target.isRanger),
        )),
      ],
    );
  }

  /* ── Step 2: Experience & Level Up ──────────────────────────── */
  Widget _buildStep2(PostGameState postGame, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${postGame.rangerName} — Session Report', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                InfoRow(label: 'XP Earned', value: '+${postGame.xpEarned} XP'),
                InfoRow(label: 'Total XP', value: '${postGame.oldXp} → ${postGame.newXp}'),
                InfoRow(label: 'Level', value: '${postGame.oldLevel} → ${postGame.newLevel}'),
                if (postGame.didLevelUp) ...[
                  const Divider(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: theme.colorScheme.tertiaryContainer, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_upward, color: theme.colorScheme.onTertiaryContainer),
                        const SizedBox(width: 8),
                        Expanded(child: Text(
                          'Level Up! Bonus: ${_bonusLabel(postGame.bonusType!)}',
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onTertiaryContainer),
                        )),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        if (postGame.didLevelUp && !postGame.levelUpApplied)
          LevelUpBonusSelector(postGame: postGame, theme: theme),

        if (postGame.levelUpApplied)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: theme.colorScheme.onPrimaryContainer),
                const SizedBox(width: 12),
                Text('Level-up bonus applied!', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)),
              ],
            ),
          ),

        if (postGame.companionPpGains.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Companion Progression', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Surviving companions earn +1 Progression Point.', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 8),
                  ...postGame.companionPpGains.map((pp) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(child: Text(pp.name, style: theme.textTheme.bodyMedium)),
                        Text('${pp.oldPp} → ${pp.newPp} PP', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                        if (pp.unclaimedRewards.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.star, color: statusAmber(theme), size: 16),
                        ],
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _bonusLabel(LevelBonusType type) {
    switch (type) {
      case LevelBonusType.improveSkills: return 'Improve Skills (+5 total)';
      case LevelBonusType.improveStats: return 'Improve Stats (+1)';
      case LevelBonusType.gainRecruitmentPoints: return 'Gain Recruitment Points (+10)';
      case LevelBonusType.newHeroicAbilityOrSpell: return 'New Heroic Ability or Spell';
    }
  }

  /* ── Step 3: Treasure Rolls ──────────────────────────────── */
  Widget _buildStep3(PostGameState postGame, ThemeData theme) {
    final notifier = ref.read(postGameProvider.notifier);
    final rolledCount = postGame.treasureResults.length;
    final remaining = postGame.treasureCount - rolledCount;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (postGame.treasureCount == 0)
          TreasureCountSetup(notifier: notifier, theme: theme)

        else ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.inventory_2, color: theme.colorScheme.primary, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Treasure Tokens: ${postGame.treasureCount}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                        Text('Rolled: $rolledCount of ${postGame.treasureCount}', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Treasure Table'),
                    onPressed: () => context.push('/reference/treasure_tables'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (remaining > 0) ...[
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      for (var i = 0; i < remaining; i++) {
                        notifier.rollTreasure();
                      }
                    },
                    icon: const Icon(Icons.casino),
                    label: Text('Roll All ($remaining remaining)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],

          ...List.generate(postGame.treasureCount, (i) {
            if (i < postGame.treasureResults.length) {
              return TreasureResultCard(
                result: postGame.treasureResults[i],
                index: i,
                theme: theme,
              );
            }
            return TreasurePendingCard(
              index: i,
              theme: theme,
              onRoll: notifier.rollTreasure,
              onManualRoll: notifier.rollTreasureManually,
            );
          }),
        ],
      ],
    );
  }

  /* ── Step 4: Reorganize Companions ────────────────────────── */
  Widget _buildStep4(PostGameState postGame, ThemeData theme) {
    final activeCompanions = postGame.currentCompanions
      .where((c) =>
        (c.isActive || postGame.reactivatedCompanionIds.contains(c.id)) &&
        !postGame.releasedCompanionIds.contains(c.id))
      .toList();
    final releasedCompanions = postGame.currentCompanions
      .where((c) =>
        (!c.isActive && !postGame.reactivatedCompanionIds.contains(c.id)) ||
        postGame.releasedCompanionIds.contains(c.id))
      .toList();
    final usedRp = activeCompanions.fold(0, (sum, c) => sum + c.rpCost);
    final remainingRp = postGame.availableRp - usedRp;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recruitment Points', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                InfoRow(label: 'Total RP', value: '${postGame.availableRp}'),
                InfoRow(label: 'RP Used (active companions)', value: '$usedRp'),
                InfoRow(label: 'RP Remaining', value: '$remainingRp'),
                if (remainingRp < 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: theme.colorScheme.error, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text(
                            'Over budget! Release companions to free up RP.',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                          )),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        Text('Active Companions (${activeCompanions.length})', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (activeCompanions.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('No active companions.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          )
        else
          ...activeCompanions.map((comp) => CompanionCard(
            companion: comp,
            isReleased: false,
            theme: theme,
            onToggle: () => ref.read(postGameProvider.notifier).releaseCompanion(comp.id),
          )),

        if (releasedCompanions.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Released Companions (${releasedCompanions.length})', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.error)),
          const SizedBox(height: 8),
          ...releasedCompanions.map((comp) => CompanionCard(
            companion: comp,
            isReleased: true,
            theme: theme,
            onToggle: () => ref.read(postGameProvider.notifier).undoReleaseCompanion(comp.id),
          )),
        ],

        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RecruitCompanionsView(
                    rangerId: postGame.rangerId,
                    baseRecruitmentPoints: postGame.availableRp,
                  ),
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.secondary,
            ),
            icon: const Icon(Icons.person_add),
            label: const Text('Recruit New Companion'),
          ),
        ),

        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Companions you release go to reserve and keep their Progression Points. '
            'You can add them back in future missions. '
            'Unused Recruitment Points are lost after this mission.',
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Future<void> _finalize(BuildContext context) async {
    final notifier = ref.read(postGameProvider.notifier);
    try {
      await notifier.finalize();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post-game results saved!'), behavior: SnackBarBehavior.floating),
        );
      }
    } on Exception catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e'), backgroundColor: Theme.of(context).colorScheme.error, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }
}
