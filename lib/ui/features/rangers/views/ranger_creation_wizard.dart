import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import '../../../../domain/constants/base_stats.dart';
import '../../../../data/database/app_database.dart';
import '../../../../data/repositories/ranger_repository_provider.dart';
import '../view_models/ranger_creation_provider.dart';
import '../view_models/rangers_provider.dart';
import 'ranger_creation_step1_name.dart';
import 'ranger_creation_step2_build_points.dart';
import 'ranger_creation_step3_equipment.dart';
import 'ranger_creation_step4_review.dart';

class RangerCreationWizardView extends ConsumerStatefulWidget {
  const RangerCreationWizardView({super.key});

  @override
  ConsumerState<RangerCreationWizardView> createState() =>
      _RangerCreationWizardViewState();
}

class _RangerCreationWizardViewState
    extends ConsumerState<RangerCreationWizardView> {
  late final PageController _pageController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Reset wizard state when entering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rangerCreationProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onStepChanged(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _createRanger() async {
    final state = ref.read(rangerCreationProvider);
    if (!state.canProceed || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final repo = ref.read(rangerRepositoryProvider);

      // Insert ranger
      final rangerId = await repo.insertRanger(RangersCompanion.insert(
        name: state.name,
        move: state.getEffectiveStat('move', rangerBaseStats.move),
        fight: state.getEffectiveStat('fight', rangerBaseStats.fight),
        shoot: state.getEffectiveStat('shoot', rangerBaseStats.shoot),
        armour: state.getEffectiveStat('armour', rangerBaseStats.armour),
        will: state.getEffectiveStat('will', rangerBaseStats.will),
        health: state.getEffectiveStat('health', rangerBaseStats.health),
        currentHealth: state.getEffectiveStat('health', rangerBaseStats.health),
        baseRecruitmentPoints: Value(state.totalRecruitmentPoints),
        notes: Value(state.notes),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      // Insert heroic abilities
      for (final abilityKey in state.selectedHeroicAbilities) {
        await repo.insertRangerAbility(RangerAbilitiesCompanion.insert(
          rangerId: rangerId,
          abilityType: 'heroic_ability',
          abilityKey: abilityKey,
        ));
      }

      // Insert spells
      for (final spellKey in state.selectedSpells) {
        await repo.insertRangerAbility(RangerAbilitiesCompanion.insert(
          rangerId: rangerId,
          abilityType: 'spell',
          abilityKey: spellKey,
        ));
      }

      // Insert skills
      for (final entry in state.skillBonuses.entries) {
        await repo.insertRangerSkill(RangerSkillsCompanion.insert(
          rangerId: rangerId,
          skillKey: entry.key,
          value: entry.value,
        ));
      }

      // Insert equipment
      int slotIndex = 0;
      for (final itemKey in state.selectedEquipment) {
        final equipment = await repo.getEquipmentByKey(itemKey);
        if (equipment != null) {
          await repo.insertRangerEquipment(RangerEquipmentCompanion.insert(
            rangerId: rangerId,
            equipmentId: equipment.id,
            currentUses: equipment.hasUses ? Value(equipment.maxUses) : const Value(null),
            slotIndex: Value(slotIndex < 6 ? slotIndex : null),
          ));
          slotIndex++;
        }
      }

      // Reset wizard and navigate back
      if (mounted) {
        ref.read(rangerCreationProvider.notifier).reset();
        ref.invalidate(rangersListProvider);
        context.go('/rangers');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating ranger: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rangerCreationProvider);
    final theme = Theme.of(context);

    // Listen for step changes
    ref.listen<RangerCreationState>(rangerCreationProvider, (previous, next) {
      if (previous?.currentStep != next.currentStep) {
        _onStepChanged(next.currentStep);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Ranger'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Step Indicator
          _StepIndicator(
            currentStep: state.currentStep,
            stepLabels: const ['Name', 'Build', 'Gear', 'Review'],
          ),
          const Divider(height: 1),

          // Page View
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                RangerCreationStep1Name(),
                RangerCreationStep2BuildPoints(),
                RangerCreationStep3Equipment(),
                RangerCreationStep4Review(),
              ],
            ),
          ),

          // Bottom Navigation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Back button
                if (state.currentStep > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSaving
                          ? null
                          : () {
                              ref.read(rangerCreationProvider.notifier).previousStep();
                            },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                    ),
                  )
                else
                  const Spacer(),

                const SizedBox(width: 16),

                // Next or Create button
                Expanded(
                  flex: state.currentStep == 3 ? 2 : 1,
                  child: state.currentStep == 3
                      ? FilledButton.icon(
                          onPressed: (!state.canProceed || _isSaving)
                              ? null
                              : _createRanger,
                          icon: _isSaving
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Theme.of(context).colorScheme.onPrimary,
                                  ),
                                )
                              : const Icon(Icons.check),
                          label: Text(_isSaving ? 'Creating...' : 'Create Ranger'),
                        )
                      : FilledButton.icon(
                          onPressed: (!state.canProceed || _isSaving)
                              ? null
                              : () {
                              ref.read(rangerCreationProvider.notifier).nextStep();
                            },
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Next'),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.currentStep,
    required this.stepLabels,
  });

  final int currentStep;
  final List<String> stepLabels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(stepLabels.length, (index) {
          final isActive = index == currentStep;
          final isCompleted = index < currentStep;

          return Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? theme.colorScheme.primary
                        : isActive
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surfaceContainerHighest,
                    border: Border.all(
                      color: isCompleted || isActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(
                            Icons.check,
                            size: 18,
                            color: theme.colorScheme.onPrimary,
                          )
                        : Text(
                            '${index + 1}',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: isActive
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.onSurfaceVariant,
                              fontWeight:
                                  isActive ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    stepLabels[index],
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isActive
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
