import 'dart:convert';
import 'dart:math' show Random;
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/database/app_database.dart' hide CompanionType;
import '../../../../data/repositories/session_repository_provider.dart';
import '../../../../data/repositories/ranger_repository_provider.dart';
import '../../../../data/repositories/companion_repository_provider.dart';
import '../../../../data/services/post_game_service.dart';
import '../../../../domain/constants/experience_table.dart' show LevelBonusType, getStatMaxValue;
import '../../../../domain/constants/permanent_injuries.dart' show PermanentInjury;
import '../../../../domain/constants/companion_progression.dart' show ProgressionReward, getUnclaimedRewards;

enum SurvivalOutcomeState { pending, rolled }

class SurvivalTargetState {
  final int id;
  final String name;
  final bool isRanger;
  final int? survivalRoll;
  final int? survivalRollModified;
  final SurvivalResult? result;
  final PermanentInjury? injury;
  final int? injuryRoll;
  final SurvivalOutcomeState outcomeState;

  const SurvivalTargetState({
    required this.id,
    required this.name,
    required this.isRanger,
    this.survivalRoll,
    this.survivalRollModified,
    this.result,
    this.injury,
    this.injuryRoll,
    this.outcomeState = SurvivalOutcomeState.pending,
  });

  SurvivalTargetState copyWith({
    int? id,
    String? name,
    bool? isRanger,
    int? survivalRoll,
    int? survivalRollModified,
    SurvivalResult? result,
    PermanentInjury? injury,
    int? injuryRoll,
    SurvivalOutcomeState? outcomeState,
  }) {
    return SurvivalTargetState(
      id: id ?? this.id,
      name: name ?? this.name,
      isRanger: isRanger ?? this.isRanger,
      survivalRoll: survivalRoll ?? this.survivalRoll,
      survivalRollModified: survivalRollModified ?? this.survivalRollModified,
      result: result ?? this.result,
      injury: injury ?? this.injury,
      injuryRoll: injuryRoll ?? this.injuryRoll,
      outcomeState: outcomeState ?? this.outcomeState,
    );
  }
}

class TreasureResultState {
  final int treasureIndex;
  final int mainRoll;
  final int subRoll;
  final String name;
  final String category;
  final String categoryName;
  final bool goldChoseXp; // for gold: true = +10 XP, false = +1 PP to companion
  final bool isGoldChoiceMade;

  const TreasureResultState({
    required this.treasureIndex,
    required this.mainRoll,
    required this.subRoll,
    required this.name,
    required this.category,
    required this.categoryName,
    this.goldChoseXp = false,
    this.isGoldChoiceMade = false,
  });

  TreasureResultState copyWith({
    int? treasureIndex,
    int? mainRoll,
    int? subRoll,
    String? name,
    String? category,
    String? categoryName,
    bool? goldChoseXp,
    bool? isGoldChoiceMade,
  }) {
    return TreasureResultState(
      treasureIndex: treasureIndex ?? this.treasureIndex,
      mainRoll: mainRoll ?? this.mainRoll,
      subRoll: subRoll ?? this.subRoll,
      name: name ?? this.name,
      category: category ?? this.category,
      categoryName: categoryName ?? this.categoryName,
      goldChoseXp: goldChoseXp ?? this.goldChoseXp,
      isGoldChoiceMade: isGoldChoiceMade ?? this.isGoldChoiceMade,
    );
  }
}

class CompanionPpState {
  final int id;
  final String name;
  final int oldPp;
  final int newPp;
  final List<ProgressionReward> unclaimedRewards;

  const CompanionPpState({
    required this.id,
    required this.name,
    required this.oldPp,
    required this.newPp,
    this.unclaimedRewards = const [],
  });
}

class CompanionWithType {
  final int id;
  final String name;
  final String typeName;
  final int rpCost;
  final bool isActive;
  final int progressionPoints;

  const CompanionWithType({
    required this.id,
    required this.name,
    required this.typeName,
    required this.rpCost,
    required this.isActive,
    required this.progressionPoints,
  });
}

class PostGameState {
  final int currentStep;

  // Session info
  final int sessionId;
  final int rangerId;
  final String rangerName;
  final String scenarioName;
  final String outcome;
  final int xpEarned;

  // Step 1: Injury & Death
  final List<SurvivalTargetState> survivalTargets;

  // Step 2: XP & Level
  final int oldXp;
  final int newXp;
  final int oldLevel;
  final int newLevel;
  final bool didLevelUp;
  final LevelBonusType? bonusType;

  // Step 2: Level-up selections
  final Map<String, int> skillAllocations; // skillKey → points to add (total 5)
  final int remainingSkillPoints;
  final String? selectedStat;
  final String? selectedHeroicAbility;
  final List<RangerSkill> rangerSkills;
  final List<RangerAbility> rangerAbilities;
  final bool levelUpApplied;
  final Ranger? ranger; // current ranger data for stat lookups

  // Step 2: Companion progression
  final List<CompanionPpState> companionPpGains;

  // Step 3: Treasure
  final int treasureCount;
  final List<TreasureResultState> treasureResults;

  // Step 4: Companions
  final int availableRp;
  final List<CompanionWithType> currentCompanions;
  final Set<int> releasedCompanionIds;

  // Finalization
  final bool isFinalized;

  const PostGameState({
    this.currentStep = 0,
    required this.sessionId,
    required this.rangerId,
    required this.rangerName,
    this.scenarioName = '',
    this.outcome = '',
    this.xpEarned = 0,
    this.survivalTargets = const [],
    this.oldXp = 0,
    this.newXp = 0,
    this.oldLevel = 0,
    this.newLevel = 0,
    this.didLevelUp = false,
    this.bonusType,
    this.skillAllocations = const {},
    this.remainingSkillPoints = 0,
    this.selectedStat,
    this.selectedHeroicAbility,
    this.rangerSkills = const [],
    this.rangerAbilities = const [],
    this.levelUpApplied = false,
    this.ranger,
    this.companionPpGains = const [],
    this.treasureCount = 0,
    this.treasureResults = const [],
    this.availableRp = 100,
    this.currentCompanions = const [],
    this.releasedCompanionIds = const {},
    this.isFinalized = false,
  });

  PostGameState copyWith({
    int? currentStep,
    int? sessionId,
    int? rangerId,
    String? rangerName,
    String? scenarioName,
    String? outcome,
    int? xpEarned,
    List<SurvivalTargetState>? survivalTargets,
    int? oldXp,
    int? newXp,
    int? oldLevel,
    int? newLevel,
    bool? didLevelUp,
    LevelBonusType? bonusType,
    Map<String, int>? skillAllocations,
    int? remainingSkillPoints,
    String? selectedStat,
    String? selectedHeroicAbility,
    List<RangerSkill>? rangerSkills,
    List<RangerAbility>? rangerAbilities,
    bool? levelUpApplied,
    Ranger? ranger,
    List<CompanionPpState>? companionPpGains,
    int? treasureCount,
    List<TreasureResultState>? treasureResults,
    int? availableRp,
    List<CompanionWithType>? currentCompanions,
    Set<int>? releasedCompanionIds,
    bool? isFinalized,
  }) {
    return PostGameState(
      currentStep: currentStep ?? this.currentStep,
      sessionId: sessionId ?? this.sessionId,
      rangerId: rangerId ?? this.rangerId,
      rangerName: rangerName ?? this.rangerName,
      scenarioName: scenarioName ?? this.scenarioName,
      outcome: outcome ?? this.outcome,
      xpEarned: xpEarned ?? this.xpEarned,
      survivalTargets: survivalTargets ?? this.survivalTargets,
      oldXp: oldXp ?? this.oldXp,
      newXp: newXp ?? this.newXp,
      oldLevel: oldLevel ?? this.oldLevel,
      newLevel: newLevel ?? this.newLevel,
      didLevelUp: didLevelUp ?? this.didLevelUp,
      bonusType: bonusType ?? this.bonusType,
      skillAllocations: skillAllocations ?? this.skillAllocations,
      remainingSkillPoints: remainingSkillPoints ?? this.remainingSkillPoints,
      selectedStat: selectedStat ?? this.selectedStat,
      selectedHeroicAbility: selectedHeroicAbility ?? this.selectedHeroicAbility,
      rangerSkills: rangerSkills ?? this.rangerSkills,
      rangerAbilities: rangerAbilities ?? this.rangerAbilities,
      levelUpApplied: levelUpApplied ?? this.levelUpApplied,
      ranger: ranger ?? this.ranger,
      companionPpGains: companionPpGains ?? this.companionPpGains,
      treasureCount: treasureCount ?? this.treasureCount,
      treasureResults: treasureResults ?? this.treasureResults,
      availableRp: availableRp ?? this.availableRp,
      currentCompanions: currentCompanions ?? this.currentCompanions,
      releasedCompanionIds: releasedCompanionIds ?? this.releasedCompanionIds,
      isFinalized: isFinalized ?? this.isFinalized,
    );
  }
}

class PostGameNotifier extends StateNotifier<PostGameState?> {
  PostGameNotifier(this._ref) : super(null);

  final Ref _ref;

  Future<void> loadFromSession(int sessionId, {List<int> deadCompanionIds = const []}) async {
    final sessionRepo = _ref.read(sessionRepositoryProvider);
    final rangerRepo = _ref.read(rangerRepositoryProvider);
    final companionRepo = _ref.read(companionRepositoryProvider);

    final session = await sessionRepo.getSessionById(sessionId);
    if (session == null) return;

    final ranger = await rangerRepo.getRangerById(session.rangerId);
    if (ranger == null) return;

    final companions = await companionRepo.getCompanionsByRanger(session.rangerId);
    final rangerSkills = await rangerRepo.getRangerSkills(ranger.id);
    final rangerAbilities = await rangerRepo.getRangerAbilities(ranger.id);

    // Determine survival targets: ranger at 0 HP + companions at 0 HP
    final targets = <SurvivalTargetState>[];

    // Check if ranger was at 0 HP at end of session
    if (ranger.currentHealth <= 0) {
      targets.add(SurvivalTargetState(
        id: ranger.id,
        name: ranger.name,
        isRanger: true,
      ));
    }

    // Companions: check deadCompanionIds list
    for (final comp in companions) {
      if (deadCompanionIds.contains(comp.id)) {
        targets.add(SurvivalTargetState(
          id: comp.id,
          name: comp.customName,
          isRanger: false,
        ));
      }
    }

    // Calculate XP
    final xp = session.experienceEarned;
    final oldXp = ranger.experiencePoints;
    final newXp = oldXp + xp;
    final oldLevel = ranger.level;
    final newLevel = calculateLevel(newXp);
    final didLevelUp = newLevel > oldLevel;
    final bonusType = didLevelUp ? bonusTypeForLevel(newLevel) : null;

    // Calculate RP
    final leadershipBonus = 0;
    final levelBonusRp = didLevelUp && bonusType == LevelBonusType.gainRecruitmentPoints ? 10 : 0;
    final rp = ranger.baseRecruitmentPoints + levelBonusRp + leadershipBonus;

    // Compute companion PP gains (surviving companions get +1 PP)
    final companionPpList = <CompanionPpState>[];
    for (final comp in companions) {
      if (!deadCompanionIds.contains(comp.id) && comp.isAlive) {
        final newPp = comp.progressionPoints + 1;
        final claimed = _parseClaimedRewards(comp.claimedProgressionRewards);
        final unclaimed = getUnclaimedRewards(newPp, claimed);
        companionPpList.add(CompanionPpState(
          id: comp.id,
          name: comp.customName,
          oldPp: comp.progressionPoints,
          newPp: newPp,
          unclaimedRewards: unclaimed,
        ));
      }
    }

    // Initialize skill allocations for Improve Skills bonus
    final initialAllocations = <String, int>{};
    final initialRemaining = bonusType == LevelBonusType.improveSkills ? 5 : 0;

    // Load companion types for RP cost calculation
    final allTypes = await companionRepo.getAllCompanionTypes();
    final typeMap = {for (final t in allTypes) t.id: t};

    // Build companion list with type info
    final companionList = <CompanionWithType>[];
    int usedRp = 0;
    for (final comp in companions) {
      final type = typeMap[comp.companionTypeId];
      final cost = type?.rpCost ?? 0;
      companionList.add(CompanionWithType(
        id: comp.id,
        name: comp.customName,
        typeName: type?.name ?? 'Unknown',
        rpCost: cost,
        isActive: comp.isActive,
        progressionPoints: comp.progressionPoints,
      ));
      if (comp.isActive) usedRp += cost;
    }

    state = PostGameState(
      sessionId: sessionId,
      rangerId: ranger.id,
      rangerName: ranger.name,
      scenarioName: session.scenarioName,
      outcome: session.outcome,
      xpEarned: xp,
      survivalTargets: targets,
      oldXp: oldXp,
      newXp: newXp,
      oldLevel: oldLevel,
      newLevel: newLevel,
      didLevelUp: didLevelUp,
      bonusType: bonusType,
      skillAllocations: initialAllocations,
      remainingSkillPoints: initialRemaining,
      rangerSkills: rangerSkills,
      rangerAbilities: rangerAbilities,
      levelUpApplied: false,
      ranger: ranger,
      companionPpGains: companionPpList,
      treasureCount: 0,
      availableRp: rp,
      currentCompanions: companionList,
      releasedCompanionIds: const {},
    );
  }

  Set<int> _parseClaimedRewards(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    try {
      return Set<int>.from(jsonDecode(raw) as List);
    } catch (_) {
      return {};
    }
  }

  void goToStep(int step) {
    if (state == null) return;
    state = state!.copyWith(currentStep: step);
  }

  void nextStep() {
    if (state == null) return;
    state = state!.copyWith(currentStep: state!.currentStep + 1);
  }

  /* ── Step 2: Experience & Level Up ─────────────────────── */
  void setSkillAllocation(String skillKey, int points) {
    if (state == null || !state!.didLevelUp) return;
    final current = state!.skillAllocations[skillKey] ?? 0;
    final oldRemaining = state!.remainingSkillPoints;
    final newPoints = (current + points).clamp(0, 2);
    final delta = newPoints - current;
    if (delta > 0 && oldRemaining < delta) return; // not enough points
    if (newPoints == current) return;

    final newAllocations = Map<String, int>.from(state!.skillAllocations);
    if (newPoints == 0) {
      newAllocations.remove(skillKey);
    } else {
      newAllocations[skillKey] = newPoints;
    }
    state = state!.copyWith(
      skillAllocations: newAllocations,
      remainingSkillPoints: oldRemaining - delta,
    );
  }

  void selectStat(String stat) {
    if (state == null || !state!.didLevelUp) return;
    state = state!.copyWith(selectedStat: stat == state!.selectedStat ? null : stat);
  }

  void selectHeroicAbility(String key) {
    if (state == null || !state!.didLevelUp) return;
    state = state!.copyWith(selectedHeroicAbility: key == state!.selectedHeroicAbility ? null : key);
  }

  void applyLevelUp() {
    if (state == null || !state!.didLevelUp || state!.levelUpApplied) return;

    final bonus = state!.bonusType;
    if (bonus == LevelBonusType.improveSkills && state!.remainingSkillPoints > 0) return;
    if (bonus == LevelBonusType.improveStats && state!.selectedStat == null) return;
    if (bonus == LevelBonusType.newHeroicAbilityOrSpell && state!.selectedHeroicAbility == null) return;

    state = state!.copyWith(levelUpApplied: true);
  }

  /* ── Step 1: Survival ──────────────────────────────────── */
  void rollSurvival(int targetId, {int? predeterminedRoll}) {
    if (state == null) return;
    final existing = state!.survivalTargets.where((t) => t.id == targetId).firstOrNull;
    if (existing == null) return;

    final roll = predeterminedRoll ?? (Random().nextInt(20) + 1);
    final modified = roll + (existing.isRanger ? 1 : 0);
    final result = rollSurvivalTable(roll, isRanger: existing.isRanger);

    state = state!.copyWith(
      survivalTargets: state!.survivalTargets.map((t) {
        if (t.id != targetId) return t;
        return t.copyWith(
          survivalRoll: roll,
          survivalRollModified: modified,
          result: result,
          outcomeState: result == SurvivalResult.permanentInjury ? t.outcomeState : SurvivalOutcomeState.rolled,
        );
      }).toList(),
    );
  }

  void rollInjury(int targetId) {
    if (state == null) return;
    final existing = state!.survivalTargets.where((t) => t.id == targetId).firstOrNull;
    if (existing == null || existing.result != SurvivalResult.permanentInjury) return;

    final roll = Random().nextInt(20) + 1;
    final injury = rollInjuryTableWithRoll(roll);

    state = state!.copyWith(
      survivalTargets: state!.survivalTargets.map((t) {
        if (t.id != targetId) return t;
        return t.copyWith(
          injuryRoll: roll,
          injury: injury,
          outcomeState: SurvivalOutcomeState.rolled,
        );
      }).toList(),
    );
  }

  void rollInjuryWithValue(int targetId, int d20) {
    if (state == null) return;
    final injury = rollInjuryTableWithRoll(d20);
    state = state!.copyWith(
      survivalTargets: state!.survivalTargets.map((t) {
        if (t.id != targetId) return t;
        return t.copyWith(
          injuryRoll: d20,
          injury: injury,
          outcomeState: SurvivalOutcomeState.rolled,
        );
      }).toList(),
    );
  }

  /* ── Step 3: Treasure ──────────────────────────────────── */
  void rollTreasure() {
    if (state == null) return;
    final index = state!.treasureResults.length;
    if (index >= state!.treasureCount) return;

    final mainRoll = Random().nextInt(20) + 1;
    final subRoll = Random().nextInt(20) + 1;
    final result = rollTreasureWithRolls(mainRoll, subRoll);

    state = state!.copyWith(
      treasureResults: [...state!.treasureResults, TreasureResultState(
        treasureIndex: index,
        mainRoll: mainRoll,
        subRoll: subRoll,
        name: result.name,
        category: result.category,
        categoryName: _treasureCategoryLabel(result.category),
      )],
    );
  }

  void rollTreasureManually(int mainRoll, int subRoll) {
    if (state == null) return;
    final index = state!.treasureResults.length;
    if (index >= state!.treasureCount) return;

    final result = rollTreasureWithRolls(mainRoll, subRoll);
    state = state!.copyWith(
      treasureResults: [...state!.treasureResults, TreasureResultState(
        treasureIndex: index,
        mainRoll: mainRoll,
        subRoll: subRoll,
        name: result.name,
        category: result.category,
        categoryName: _treasureCategoryLabel(result.category),
      )],
    );
  }

  void setTreasureGoldChoice(int index, bool chooseXp) {
    if (state == null) return;
    final results = [...state!.treasureResults];
    if (index >= results.length) return;
    if (results[index].category != 'gold') return;

    results[index] = results[index].copyWith(
      goldChoseXp: chooseXp,
      isGoldChoiceMade: true,
    );
    state = state!.copyWith(treasureResults: results);
  }

  void setTreasureCount(int count) {
    if (state == null) return;
    state = state!.copyWith(treasureCount: count);
  }

  String _treasureCategoryLabel(String category) {
    switch (category) {
      case 'gold': return 'Gold and Jewels';
      case 'herb_potion': return 'Herb or Potion';
      case 'weapon_armour': return 'Weapon or Armour';
      case 'magic_item': return 'Magic Item';
      default: return category;
    }
  }

  /* ── Step 4: Reorganize Companions ─────────────────────── */
  void releaseCompanion(int companionId) {
    if (state == null) return;
    final ids = {...state!.releasedCompanionIds, companionId};
    state = state!.copyWith(releasedCompanionIds: ids);
  }

  void undoReleaseCompanion(int companionId) {
    if (state == null) return;
    final ids = {...state!.releasedCompanionIds}..remove(companionId);
    state = state!.copyWith(releasedCompanionIds: ids);
  }

  /* ── Finalize ──────────────────────────────────────────── */
  Future<void> finalize() async {
    if (state == null) return;

    final rangerRepo = _ref.read(rangerRepositoryProvider);
    final companionRepo = _ref.read(companionRepositoryProvider);
    final sessionRepo = _ref.read(sessionRepositoryProvider);

    // ── Update ranger XP and level ──────────────────────────
    await rangerRepo.updateRangerFields(state!.rangerId, RangersCompanion(
      level: Value(state!.newLevel),
      experiencePoints: Value(state!.newXp),
    ));

    // ── Heal ranger to full ─────────────────────────────────
    final ranger = await rangerRepo.getRangerById(state!.rangerId);

    // ── Apply level-up choices ──────────────────────────────
    final bonus = state!.bonusType;
    if (state!.didLevelUp && state!.levelUpApplied) {
      if (bonus == LevelBonusType.gainRecruitmentPoints && ranger != null) {
        await rangerRepo.updateRangerFields(state!.rangerId, RangersCompanion(
          baseRecruitmentPoints: Value(ranger.baseRecruitmentPoints + 10),
        ));
      } else if (bonus == LevelBonusType.improveSkills) {
        for (final entry in state!.skillAllocations.entries) {
          final existing = state!.rangerSkills.where((s) => s.skillKey == entry.key).firstOrNull;
          final newValue = (existing?.value ?? 0) + entry.value;
          if (existing != null) {
            await rangerRepo.updateRangerSkill(RangerSkillsCompanion(
              id: Value(existing.id),
              rangerId: Value(existing.rangerId),
              skillKey: Value(existing.skillKey),
              value: Value(newValue),
            ));
          } else {
            await rangerRepo.insertRangerSkill(RangerSkillsCompanion(
              rangerId: Value(state!.rangerId),
              skillKey: Value(entry.key),
              value: Value(newValue),
            ));
          }
        }
      } else if (bonus == LevelBonusType.improveStats && state!.selectedStat != null && ranger != null) {
        final stat = state!.selectedStat!;
        final currentValue = _getRangerStat(ranger, stat);
        final maxValue = getStatMaxValue(stat);
        final newValue = (currentValue + 1).clamp(0, maxValue);
        await rangerRepo.updateRangerFields(state!.rangerId, RangersCompanion(
          move: stat == 'move' ? Value(newValue) : Value.absent(),
          fight: stat == 'fight' ? Value(newValue) : Value.absent(),
          shoot: stat == 'shoot' ? Value(newValue) : Value.absent(),
          will: stat == 'will' ? Value(newValue) : Value.absent(),
          health: stat == 'health' ? Value(newValue) : Value.absent(),
        ));
      } else if (bonus == LevelBonusType.newHeroicAbilityOrSpell && state!.selectedHeroicAbility != null) {
        await rangerRepo.insertRangerAbility(RangerAbilitiesCompanion(
          rangerId: Value(state!.rangerId),
          abilityKey: Value(state!.selectedHeroicAbility!),
          abilityType: const Value('heroic_ability'),
        ));
      }
    }

    // Heal ranger to full after stat improvements
    if (ranger != null) {
      await sessionRepo.updateRangerCurrentHealth(state!.rangerId, ranger.health);
    }

    // ── Process survival outcomes ───────────────────────────
    for (final target in state!.survivalTargets) {
      if (target.result == null) continue;

      if (target.isRanger) {
        if (target.result == SurvivalResult.dead) {
          // Game over for ranger
        } else if (target.result == SurvivalResult.permanentInjury && target.injury != null) {
          final existing = await rangerRepo.getRangerById(target.id);
          if (existing != null) {
            final notes = '${existing.notes}\n[Injury] ${target.injury!.name}: ${target.injury!.effect}';
            await rangerRepo.updateRangerFields(target.id, RangersCompanion(
              notes: Value(notes),
            ));
          }
        }
      } else {
        final existing = await companionRepo.getCompanionById(target.id);
        if (existing == null) continue;

        if (target.result == SurvivalResult.dead) {
          await companionRepo.deleteCompanion(target.id);
        } else {
          List<String> injuries = [];
          try {
            injuries = List<String>.from(jsonDecode(existing.permanentInjuries) as List? ?? []);
          } catch (_) {}

          if (target.result == SurvivalResult.permanentInjury && target.injury != null) {
            injuries.add(target.injury!.key);
          }

          await companionRepo.updateCompanion(RangerCompanionsCompanion(
            id: Value(existing.id),
            rangerId: Value(existing.rangerId),
            companionTypeId: Value(existing.companionTypeId),
            customName: Value(existing.customName),
            progressionPoints: Value(existing.progressionPoints),
            isAlive: Value(target.result != SurvivalResult.dead),
            permanentInjuries: Value(jsonEncode(injuries)),
            customSkills: Value(existing.customSkills),
            isActive: Value(existing.isActive),
            claimedProgressionRewards: Value(existing.claimedProgressionRewards),
            hasUsedRecruitmentBonus: Value(existing.hasUsedRecruitmentBonus),
            bonusHealth: Value(existing.bonusHealth),
          ));
        }
      }
    }

    // ── Apply companion PP gains ───────────────────────────
    for (final ppState in state!.companionPpGains) {
      final existing = await companionRepo.getCompanionById(ppState.id);
      if (existing == null) continue;

      await companionRepo.updateCompanion(RangerCompanionsCompanion(
        id: Value(existing.id),
        rangerId: Value(existing.rangerId),
        companionTypeId: Value(existing.companionTypeId),
        customName: Value(existing.customName),
        progressionPoints: Value(ppState.newPp),
        isAlive: Value(existing.isAlive),
        permanentInjuries: Value(existing.permanentInjuries),
        customSkills: Value(existing.customSkills),
        isActive: Value(existing.isActive),
        claimedProgressionRewards: Value(existing.claimedProgressionRewards),
        hasUsedRecruitmentBonus: Value(existing.hasUsedRecruitmentBonus),
        bonusHealth: Value(existing.bonusHealth),
      ));
    }

    // ── Process treasure results ────────────────────────────
    final collectedItems = <String>[];
    for (final tr in state!.treasureResults) {
      if (tr.category == 'gold') {
        if (tr.isGoldChoiceMade && tr.goldChoseXp) {
          // Apply +10 XP to ranger
          final currentRanger = await rangerRepo.getRangerById(state!.rangerId);
          if (currentRanger != null) {
            await rangerRepo.updateRangerFields(state!.rangerId, RangersCompanion(
              experiencePoints: Value(currentRanger.experiencePoints + 10),
            ));
          }
        }
      } else {
        collectedItems.add('${tr.name} (${tr.categoryName})');
      }
    }

    if (collectedItems.isNotEmpty) {
      final ranger = await rangerRepo.getRangerById(state!.rangerId);
      if (ranger != null) {
        final itemsNote = '\n[Treasure] ${collectedItems.join(', ')}';
        await rangerRepo.updateRangerFields(state!.rangerId, RangersCompanion(
          notes: Value('${ranger.notes}$itemsNote'),
        ));
      }
    }

    // ── Process companion releases ─────────────────────────
    for (final releasedId in state!.releasedCompanionIds) {
      final existing = await companionRepo.getCompanionById(releasedId);
      if (existing == null) continue;
      await companionRepo.updateCompanion(RangerCompanionsCompanion(
        id: Value(existing.id),
        rangerId: Value(existing.rangerId),
        companionTypeId: Value(existing.companionTypeId),
        customName: Value(existing.customName),
        progressionPoints: Value(existing.progressionPoints),
        isAlive: Value(existing.isAlive),
        permanentInjuries: Value(existing.permanentInjuries),
        customSkills: Value(existing.customSkills),
        isActive: const Value(false),
        claimedProgressionRewards: Value(existing.claimedProgressionRewards),
        hasUsedRecruitmentBonus: Value(existing.hasUsedRecruitmentBonus),
        bonusHealth: Value(existing.bonusHealth),
      ));
    }

    state = state!.copyWith(isFinalized: true);
  }

  int _getRangerStat(Ranger ranger, String stat) {
    switch (stat) {
      case 'move': return ranger.move;
      case 'fight': return ranger.fight;
      case 'shoot': return ranger.shoot;
      case 'will': return ranger.will;
      case 'health': return ranger.health;
      default: return 0;
    }
  }
}

final postGameProvider = StateNotifierProvider<PostGameNotifier, PostGameState?>((ref) {
  return PostGameNotifier(ref);
});
