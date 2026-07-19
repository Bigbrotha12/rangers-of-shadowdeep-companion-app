import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/data/services/post_game_service.dart';
import 'package:rangers_mobile/domain/constants/skills.dart';
import 'package:rangers_mobile/domain/constants/heroic_abilities.dart';
import 'package:rangers_mobile/domain/constants/experience_table.dart';
import 'package:rangers_mobile/ui/core/theme/app_colors.dart';
import 'package:rangers_mobile/ui/features/companions/views/recruit_companions_view.dart';
import 'package:rangers_mobile/ui/features/session/view_models/post_game_provider.dart';
import 'package:rangers_mobile/ui/features/session/view_models/post_game_state.dart';
import 'package:rangers_mobile/ui/features/session/view_models/session_provider.dart';

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
      // Read dead companion IDs from the active session state
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
          // ── Step 1: Injury & Death ──────────────────────────
          Step(
            title: const Text('Injury & Death'),
            subtitle: const Text('Check who survived'),
            isActive: postGame.currentStep >= 0,
            state: _stepState(0, postGame),
            content: _buildStep1(postGame, theme),
          ),
          // ── Step 2: Experience & Level Up ──────────────────
          Step(
            title: const Text('Experience & Level'),
            subtitle: const Text('Award XP and level up'),
            isActive: postGame.currentStep >= 1,
            state: _stepState(1, postGame),
            content: _buildStep2(postGame, theme),
          ),
          // ── Step 3: Treasure Rolls ─────────────────────────
          Step(
            title: const Text('Treasure'),
            subtitle: const Text('Roll for treasure tokens'),
            isActive: postGame.currentStep >= 2,
            state: _stepState(2, postGame),
            content: _buildStep3(postGame, theme),
          ),
          // ── Step 4: Reorganize Companions ──────────────────
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
        ...postGame.survivalTargets.map((target) => _SurvivalCard(
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
        // ── XP & Level Summary ──────────────────────────────
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${postGame.rangerName} — Session Report', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _InfoRow(label: 'XP Earned', value: '+${postGame.xpEarned} XP'),
                _InfoRow(label: 'Total XP', value: '${postGame.oldXp} → ${postGame.newXp}'),
                _InfoRow(label: 'Level', value: '${postGame.oldLevel} → ${postGame.newLevel}'),
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

        // ── Level-Up Bonus Selection ────────────────────────
        if (postGame.didLevelUp && !postGame.levelUpApplied)
          _LevelUpBonusSelector(postGame: postGame, theme: theme),

        // ── Level-Up Applied Banner ─────────────────────────
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

        // ── Companion Progression ───────────────────────────
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
        // ── Treasure Count Setup ─────────────────────────────
        if (postGame.treasureCount == 0)
          _TreasureCountSetup(notifier: notifier, theme: theme)

        else ...[
          // ── Info Header ───────────────────────────────────
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

          // ── Roll All Remaining Button ─────────────────────
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

          // ── Individual Treasure Cards ─────────────────────
          ...List.generate(postGame.treasureCount, (i) {
            if (i < postGame.treasureResults.length) {
              return _TreasureResultCard(
                result: postGame.treasureResults[i],
                index: i,
                theme: theme,
              );
            }
            return _TreasurePendingCard(
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
        // ── RP Summary ──────────────────────────────────────
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recruitment Points', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _InfoRow(label: 'Total RP', value: '${postGame.availableRp}'),
                _InfoRow(label: 'RP Used (active companions)', value: '$usedRp'),
                _InfoRow(label: 'RP Remaining', value: '$remainingRp'),
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

        // ── Active Companions ───────────────────────────────
        Text('Active Companions (${activeCompanions.length})', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (activeCompanions.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('No active companions.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          )
        else
          ...activeCompanions.map((comp) => _CompanionCard(
            companion: comp,
            isReleased: false,
            theme: theme,
            onToggle: () => ref.read(postGameProvider.notifier).releaseCompanion(comp.id),
          )),

        // ── Released Companions ─────────────────────────────
        if (releasedCompanions.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Released Companions (${releasedCompanions.length})', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.error)),
          const SizedBox(height: 8),
          ...releasedCompanions.map((comp) => _CompanionCard(
            companion: comp,
            isReleased: true,
            theme: theme,
            onToggle: () => ref.read(postGameProvider.notifier).undoReleaseCompanion(comp.id),
          )),
        ],

        // ── Recruit Button ──────────────────────────────────
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

        // ── Info Note ───────────────────────────────────────
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

/* ── Survival Target Card ───────────────────────────────────── */
class _SurvivalCard extends ConsumerStatefulWidget {
  final SurvivalTargetState target;
  final VoidCallback onRoll;
  final ValueChanged<int> onManualRoll;
  final VoidCallback onRollInjury;
  final ValueChanged<int> onManualInjuryRoll;

  const _SurvivalCard({
    required this.target,
    required this.onRoll,
    required this.onManualRoll,
    required this.onRollInjury,
    required this.onManualInjuryRoll,
  });

  @override
  ConsumerState<_SurvivalCard> createState() => _SurvivalCardState();
}

class _SurvivalCardState extends ConsumerState<_SurvivalCard> {
  final _manualRollController = TextEditingController();
  final _manualInjuryController = TextEditingController();

  @override
  void dispose() {
    _manualRollController.dispose();
    _manualInjuryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final target = widget.target;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: target.isRanger ? theme.colorScheme.surfaceContainerHighest : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: target.isRanger ? theme.colorScheme.primary : theme.colorScheme.secondaryContainer,
                  child: Icon(target.isRanger ? Icons.person : Icons.pets, color: target.isRanger ? theme.colorScheme.onPrimary : theme.colorScheme.onSecondaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(target.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      Text(target.isRanger ? 'Ranger' : 'Companion', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                if (target.result != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _outcomeColor(target.result!, theme).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _outcomeColor(target.result!, theme)),
                    ),
                    child: Text(_outcomeLabel(target.result!), style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: _outcomeColor(target.result!, theme))),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Survival Roll
            if (target.result == null) ...[
              Row(
                children: [
                  FilledButton.tonalIcon(
                    onPressed: widget.onRoll,
                    icon: const Icon(Icons.casino),
                    label: const Text('Roll d20'),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _manualRollController,
                      decoration: const InputDecoration(
                        labelText: 'Manual',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: () {
                      final roll = int.tryParse(_manualRollController.text);
                      if (roll != null && roll >= 1 && roll <= 20) {
                        widget.onManualRoll(roll);
                      }
                    },
                    child: const Text('Set'),
                  ),
                ],
              ),
              if (target.isRanger)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('Rangers add +1 to the roll', style: theme.textTheme.labelSmall?.copyWith(fontStyle: FontStyle.italic)),
                ),
            ],

            // Result Display
            if (target.result != null) ...[
              _OutcomeDetail(target: target, theme: theme),

              // Permanent Injury sub-step
              if (target.result == SurvivalResult.permanentInjury && target.injury == null) ...[
                const SizedBox(height: 12),
                const Divider(),
                Text('Roll on Permanent Injury Table (d20)', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: widget.onRollInjury,
                      icon: const Icon(Icons.casino),
                      label: const Text('Roll d20'),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _manualInjuryController,
                        decoration: const InputDecoration(
                          labelText: 'Manual',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonal(
                      onPressed: () {
                        final roll = int.tryParse(_manualInjuryController.text);
                        if (roll != null && roll >= 1 && roll <= 20) {
                          widget.onManualInjuryRoll(roll);
                        }
                      },
                      child: const Text('Set'),
                    ),
                  ],
                ),
              ],

              // Injury Detail
              if (target.injury != null) ...[
                const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusOrange(theme).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusOrange(theme)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.healing, color: statusOrange(theme)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(target.injury!.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: statusOrange(theme))),
                            Text(target.injury!.effect, style: theme.textTheme.bodySmall),
                          ],
                        )),
                      ],
                    ),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Color _outcomeColor(SurvivalResult result, ThemeData theme) {
    switch (result) {
      case SurvivalResult.dead: return theme.colorScheme.error;
      case SurvivalResult.permanentInjury: return statusOrange(theme);
      case SurvivalResult.badlyWounded: return statusAmber(theme);
      case SurvivalResult.closeCall: return statusBlue(theme);
      case SurvivalResult.fullRecovery: return statusGreen(theme);
    }
  }

  String _outcomeLabel(SurvivalResult result) {
    switch (result) {
      case SurvivalResult.dead: return 'DEAD';
      case SurvivalResult.permanentInjury: return 'PERMANENT INJURY';
      case SurvivalResult.badlyWounded: return 'BADLY WOUNDED';
      case SurvivalResult.closeCall: return 'CLOSE CALL';
      case SurvivalResult.fullRecovery: return 'FULL RECOVERY';
    }
  }
}

class _OutcomeDetail extends StatelessWidget {
  final SurvivalTargetState target;
  final ThemeData theme;

  const _OutcomeDetail({required this.target, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _color().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_icon(), color: _color()),
              const SizedBox(width: 12),
              Expanded(child: Text(
                _message(),
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: _color()),
              )),
            ],
          ),
          if (target.survivalRoll != null) ...[
            const SizedBox(height: 6),
            Text(
              'd20: ${target.survivalRoll}${target.isRanger ? " (${target.survivalRollModified})" : ""}',
              style: theme.textTheme.bodySmall?.copyWith(color: _color()),
            ),
            if (target.injuryRoll != null)
              Text(
                'Injury d20: ${target.injuryRoll}',
                style: theme.textTheme.bodySmall?.copyWith(color: statusOrange(theme)),
              ),
          ],
        ],
      ),
    );
  }

  Color _color() {
    switch (target.result!) {
      case SurvivalResult.dead: return theme.colorScheme.error;
      case SurvivalResult.permanentInjury: return statusOrange(theme);
      case SurvivalResult.badlyWounded: return statusAmber(theme);
      case SurvivalResult.closeCall: return statusBlue(theme);
      case SurvivalResult.fullRecovery: return statusGreen(theme);
    }
  }

  IconData _icon() {
    switch (target.result!) {
      case SurvivalResult.dead: return Icons.dangerous;
      case SurvivalResult.permanentInjury: return Icons.healing;
      case SurvivalResult.badlyWounded: return Icons.warning;
      case SurvivalResult.closeCall: return Icons.shield;
      case SurvivalResult.fullRecovery: return Icons.check_circle;
    }
  }

  String _message() {
    switch (target.result!) {
      case SurvivalResult.dead:
        return target.isRanger
            ? 'Your ranger has fallen. Start a new campaign.'
            : 'The companion has died. All items are lost.';
      case SurvivalResult.permanentInjury:
        return 'Roll on the Permanent Injury Table to determine the injury.';
      case SurvivalResult.badlyWounded:
        return 'Starts next game at -5 Health.';
      case SurvivalResult.closeCall:
        return 'Escapes with only minor injuries. Loses all non-standard equipment.';
      case SurvivalResult.fullRecovery:
        return 'Returns next scenario at full Health.';
    }
  }
}

/* ── Level-Up Bonus Selector ─────────────────────────────── */
class _LevelUpBonusSelector extends ConsumerStatefulWidget {
  final PostGameState postGame;
  final ThemeData theme;

  const _LevelUpBonusSelector({required this.postGame, required this.theme});

  @override
  ConsumerState<_LevelUpBonusSelector> createState() => _LevelUpBonusSelectorState();
}

class _LevelUpBonusSelectorState extends ConsumerState<_LevelUpBonusSelector> {
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

  /* ── Improve Skills ────────────────────────────────────── */
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

  /* ── Improve Stats ─────────────────────────────────────── */
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

  /* ── Gain Recruitment Points ───────────────────────────── */
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

  /* ── New Heroic Ability ─────────────────────────────────── */
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

/* ── Treasure: Count Setup ────────────────────────────────── */
class _TreasureCountSetup extends StatefulWidget {
  final PostGameNotifier notifier;
  final ThemeData theme;

  const _TreasureCountSetup({required this.notifier, required this.theme});

  @override
  State<_TreasureCountSetup> createState() => _TreasureCountSetupState();
}

class _TreasureCountSetupState extends State<_TreasureCountSetup> {
  final _controller = TextEditingController(text: '1');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How many treasure tokens were secured?', style: widget.theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Treasure',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () {
                    final count = int.tryParse(_controller.text);
                    if (count != null && count > 0) {
                      widget.notifier.setTreasureCount(count);
                    }
                  },
                  child: const Text('Set'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* ── Treasure: Pending Roll Card ──────────────────────────── */
class _TreasurePendingCard extends StatefulWidget {
  final int index;
  final ThemeData theme;
  final VoidCallback onRoll;
  final void Function(int main, int sub) onManualRoll;

  const _TreasurePendingCard({
    required this.index,
    required this.theme,
    required this.onRoll,
    required this.onManualRoll,
  });

  @override
  State<_TreasurePendingCard> createState() => _TreasurePendingCardState();
}

class _TreasurePendingCardState extends State<_TreasurePendingCard> {
  final _mainController = TextEditingController();
  final _subController = TextEditingController();

  @override
  void dispose() {
    _mainController.dispose();
    _subController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: widget.theme.colorScheme.tertiaryContainer,
                  child: Text('${widget.index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Treasure ${widget.index + 1}', style: widget.theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                ),
                FilledButton.tonalIcon(
                  onPressed: widget.onRoll,
                  icon: const Icon(Icons.casino),
                  label: const Text('Roll d20'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Text('Manual Roll:', style: widget.theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _mainController,
                    decoration: const InputDecoration(
                      hintText: '1-20',
                      labelText: 'Main',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _subController,
                    decoration: const InputDecoration(
                      hintText: '1-20',
                      labelText: 'Sub',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.tonal(
                  onPressed: () {
                    final main = int.tryParse(_mainController.text);
                    final sub = int.tryParse(_subController.text);
                    if (main != null && sub != null && main >= 1 && main <= 20 && sub >= 1 && sub <= 20) {
                      widget.onManualRoll(main, sub);
                    }
                  },
                  child: const Text('Set'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* ── Treasure: Result Card ─────────────────────────────────── */
class _TreasureResultCard extends ConsumerWidget {
  final TreasureResultState result;
  final int index;
  final ThemeData theme;

  const _TreasureResultCard({
    required this.result,
    required this.index,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _categoryColor().withValues(alpha: 0.2),
                  child: Icon(_categoryIcon(), color: _categoryColor(), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(result.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                      Text(result.categoryName, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _categoryColor().withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('#${result.treasureIndex + 1}', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Roll display
            Row(
              children: [
                _RollChip(label: 'Main', roll: result.mainRoll, theme: theme),
                const SizedBox(width: 8),
                _RollChip(label: 'Sub', roll: result.subRoll, theme: theme),
              ],
            ),

            // Gold choice
            if (result.category == 'gold' && !result.isGoldChoiceMade) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Text('Choose reward:', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => ref.read(postGameProvider.notifier).setTreasureGoldChoice(index, true),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.secondary,
                      ),
                      icon: const Icon(Icons.star, size: 18),
                      label: const Text('+10 XP'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => ref.read(postGameProvider.notifier).setTreasureGoldChoice(index, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.secondary,
                      ),
                      icon: const Icon(Icons.people, size: 18),
                      label: const Text('+1 PP to Companion'),
                    ),
                  ),
                ],
              ),
            ],
            if (result.isGoldChoiceMade) ...[
              const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusGreen(theme).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: statusGreen(theme), size: 18),
                      const SizedBox(width: 8),
                      Text(result.goldChoseXp ? '+10 XP applied' : '+1 PP awarded to companion',
                        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: statusGreen(theme))),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Color _categoryColor() {
    switch (result.category) {
      case 'gold': return statusAmber(theme);
      case 'herb_potion': return statusGreen(theme);
      case 'weapon_armour': return statusBlue(theme);
      case 'magic_item': return statusPurple(theme);
      default: return statusGrey(theme);
    }
  }

  IconData _categoryIcon() {
    switch (result.category) {
      case 'gold': return Icons.monetization_on;
      case 'herb_potion': return Icons.medication;
      case 'weapon_armour': return Icons.shield;
      case 'magic_item': return Icons.auto_awesome;
      default: return Icons.inventory_2;
    }
  }
}

/* ── Roll Chip ──────────────────────────────────────────────── */
class _RollChip extends StatelessWidget {
  final String label;
  final int roll;
  final ThemeData theme;

  const _RollChip({required this.label, required this.roll, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('$label: $roll', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
    );
  }
}

/* ── Companion Card ─────────────────────────────────────────── */
class _CompanionCard extends StatelessWidget {
  final CompanionWithType companion;
  final bool isReleased;
  final ThemeData theme;
  final VoidCallback onToggle;

  const _CompanionCard({
    required this.companion,
    required this.isReleased,
    required this.theme,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isReleased ? theme.colorScheme.surfaceContainerHighest : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isReleased ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.secondaryContainer,
              child: Text('${companion.progressionPoints}', style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isReleased ? theme.colorScheme.onSurfaceVariant : null,
              )),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(companion.name, style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isReleased ? theme.colorScheme.onSurfaceVariant : null,
                    decoration: isReleased ? TextDecoration.lineThrough : null,
                  )),
                  Text('${companion.typeName} — ${companion.rpCost} RP',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
                ],
              ),
            ),
            Text('${companion.rpCost} RP', style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isReleased ? theme.colorScheme.error : theme.colorScheme.secondary,
            )),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                isReleased ? Icons.undo : Icons.person_remove,
                color: isReleased ? theme.colorScheme.secondary : theme.colorScheme.error,
              ),
              onPressed: onToggle,
              tooltip: isReleased ? 'Keep in company' : 'Release to reserve',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
