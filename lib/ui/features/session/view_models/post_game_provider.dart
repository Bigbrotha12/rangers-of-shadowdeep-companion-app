import 'dart:convert';
import 'dart:math' show Random, max;
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/ui/features/rangers/view_models/ranger_detail_provider.dart';
import 'package:rangers_mobile/data/repositories/session_repository_provider.dart';
import 'package:rangers_mobile/data/repositories/ranger_repository_provider.dart';
import 'package:rangers_mobile/data/repositories/companion_repository_provider.dart';
import 'package:rangers_mobile/data/services/post_game_service.dart';
import 'package:rangers_mobile/domain/constants/experience_table.dart' show LevelBonusType, getStatMaxValue;
import 'package:rangers_mobile/domain/constants/permanent_injuries.dart' show canApplyInjury;
import 'package:rangers_mobile/domain/constants/companion_progression.dart' show getUnclaimedRewards;
import 'package:rangers_mobile/ui/features/session/view_models/post_game_state.dart';

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
    const leadershipBonus = 0;
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
    }

    // Parse treasure count from session notes
    int treasureCount = 0;
    if (session.notes.startsWith('__treasure_count:')) {
      treasureCount = int.tryParse(session.notes.substring('__treasure_count:'.length)) ?? 0;
    } else if (session.notes.startsWith('Treasure Found:')) {
      final afterPrefix = session.notes.substring('Treasure Found:'.length).trim();
      final spaceIdx = afterPrefix.indexOf(' ');
      treasureCount = int.tryParse(spaceIdx > 0 ? afterPrefix.substring(0, spaceIdx) : afterPrefix) ?? 0;
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
      ranger: ranger,
      companionPpGains: companionPpList,
      treasureCount: treasureCount,
      availableRp: rp,
      currentCompanions: companionList,
    );
  }

  Set<int> _parseClaimedRewards(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    try {
      return Set<int>.from(jsonDecode(raw) as List);
    } on FormatException catch (_) {
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
    if (delta > 0 && oldRemaining < delta) return;
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
  void rollSurvival(int targetId, {required bool isRanger, int? predeterminedRoll}) {
    if (state == null) return;
    final existing = state!.survivalTargets.where((t) => t.id == targetId && t.isRanger == isRanger).firstOrNull;
    if (existing == null) return;

    final roll = predeterminedRoll ?? (Random().nextInt(20) + 1);
    final modified = roll + (existing.isRanger ? 1 : 0);
    final result = rollSurvivalTable(roll, isRanger: existing.isRanger);

    state = state!.copyWith(
      survivalTargets: state!.survivalTargets.map((t) {
        if (t.id != targetId || t.isRanger != isRanger) return t;
        return t.copyWith(
          survivalRoll: roll,
          survivalRollModified: modified,
          result: result,
          outcomeState: result == SurvivalResult.permanentInjury ? t.outcomeState : SurvivalOutcomeState.rolled,
        );
      }).toList(),
    );
  }

  void rollInjury(int targetId, {required bool isRanger}) {
    if (state == null) return;
    final existing = state!.survivalTargets.where((t) => t.id == targetId && t.isRanger == isRanger).firstOrNull;
    if (existing == null || existing.result != SurvivalResult.permanentInjury) return;

    final roll = Random().nextInt(20) + 1;
    final injury = rollInjuryTableWithRoll(roll);

    state = state!.copyWith(
      survivalTargets: state!.survivalTargets.map((t) {
        if (t.id != targetId || t.isRanger != isRanger) return t;
        return t.copyWith(
          injuryRoll: roll,
          injury: injury,
          outcomeState: SurvivalOutcomeState.rolled,
        );
      }).toList(),
    );
  }

  void rollInjuryWithValue(int targetId, int d20, {required bool isRanger}) {
    if (state == null) return;
    final injury = rollInjuryTableWithRoll(d20);
    state = state!.copyWith(
      survivalTargets: state!.survivalTargets.map((t) {
        if (t.id != targetId || t.isRanger != isRanger) return t;
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
    final releasedIds = {...state!.releasedCompanionIds, companionId};
    final reactivatedIds = {...state!.reactivatedCompanionIds}..remove(companionId);
    state = state!.copyWith(
      releasedCompanionIds: releasedIds,
      reactivatedCompanionIds: reactivatedIds,
    );
  }

  void undoReleaseCompanion(int companionId) {
    if (state == null) return;
    final releasedIds = {...state!.releasedCompanionIds}..remove(companionId);
    final reactivatedIds = {...state!.reactivatedCompanionIds};
    final companion = state!.currentCompanions.where((c) => c.id == companionId).firstOrNull;
    if (companion != null && !companion.isActive) {
      reactivatedIds.add(companionId);
    }
    state = state!.copyWith(
      releasedCompanionIds: releasedIds,
      reactivatedCompanionIds: reactivatedIds,
    );
  }

  /* ── Finalize ──────────────────────────────────────────── */
  Future<void> finalize() async {
    if (state == null) return;

    await _updateXpAndLevel();
    await _applyLevelUpBonus();
    await _applyHealthPenalties();
    await _processSurvivalOutcomes();
    await _applyCompanionPpGains();
    await _processTreasure();
    await _stripCloseCallEquipment();
    await _releaseCompanions();
    await _reactivateCompanions();
    await _enrichSessionNotes();

    _ref.invalidate(rangerDetailProvider(state!.rangerId));
    state = state!.copyWith(isFinalized: true);
  }

  Future<void> _updateXpAndLevel() async {
    final rangerRepo = _ref.read(rangerRepositoryProvider);
    await rangerRepo.updateRangerFields(state!.rangerId, RangersCompanion(
      level: Value(state!.newLevel),
      experiencePoints: Value(state!.newXp),
    ));
  }

  Future<void> _applyLevelUpBonus() async {
    if (!state!.didLevelUp || !state!.levelUpApplied) return;

    final rangerRepo = _ref.read(rangerRepositoryProvider);
    final bonus = state!.bonusType;
    final ranger = await rangerRepo.getRangerById(state!.rangerId);

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
        move: stat == 'move' ? Value(newValue) : const Value.absent(),
        fight: stat == 'fight' ? Value(newValue) : const Value.absent(),
        shoot: stat == 'shoot' ? Value(newValue) : const Value.absent(),
        will: stat == 'will' ? Value(newValue) : const Value.absent(),
        health: stat == 'health' ? Value(newValue) : const Value.absent(),
      ));
    } else if (bonus == LevelBonusType.newHeroicAbilityOrSpell && state!.selectedHeroicAbility != null) {
      await rangerRepo.insertRangerAbility(RangerAbilitiesCompanion(
        rangerId: Value(state!.rangerId),
        abilityKey: Value(state!.selectedHeroicAbility!),
        abilityType: const Value('heroic_ability'),
      ));
    }
  }

  Future<void> _applyHealthPenalties() async {
    final rangerRepo = _ref.read(rangerRepositoryProvider);
    final sessionRepo = _ref.read(sessionRepositoryProvider);
    final ranger = await rangerRepo.getRangerById(state!.rangerId);
    if (ranger == null) return;

    final badlyWounded = state!.survivalTargets
        .any((t) => t.isRanger && t.result == SurvivalResult.badlyWounded);
    if (badlyWounded) {
      final reducedHealth = max(1, ranger.health - 5);
      await sessionRepo.updateRangerCurrentHealth(state!.rangerId, reducedHealth);
    } else {
      await sessionRepo.updateRangerCurrentHealth(state!.rangerId, ranger.health);
    }
  }

  Future<void> _processSurvivalOutcomes() async {
    final rangerRepo = _ref.read(rangerRepositoryProvider);
    final companionRepo = _ref.read(companionRepositoryProvider);

    for (final target in state!.survivalTargets) {
      if (target.result == null) continue;

      if (target.isRanger) {
        if (target.result == SurvivalResult.permanentInjury && target.injury != null) {
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
          } on FormatException catch (_) {}

          if (target.result == SurvivalResult.permanentInjury && target.injury != null) {
            if (canApplyInjury(injuries, target.injury!.key)) {
              injuries.add(target.injury!.key);
            }
          }

          final newBonusHealth = target.result == SurvivalResult.badlyWounded
              ? max(-5, existing.bonusHealth - 5)
              : existing.bonusHealth;

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
            bonusHealth: Value(newBonusHealth),
            heroicAbilityKeys: Value(existing.heroicAbilityKeys),
            spellKeys: Value(existing.spellKeys),
          ));
        }
      }
    }
  }

  Future<void> _applyCompanionPpGains() async {
    final companionRepo = _ref.read(companionRepositoryProvider);

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
        heroicAbilityKeys: Value(existing.heroicAbilityKeys),
        spellKeys: Value(existing.spellKeys),
      ));
    }
  }

  Future<void> _processTreasure() async {
    final rangerRepo = _ref.read(rangerRepositoryProvider);

    final collectedItems = <String>[];
    final allEquipment = await rangerRepo.getAllEquipment();
    for (final tr in state!.treasureResults) {
      if (tr.category == 'gold') {
        if (tr.isGoldChoiceMade && tr.goldChoseXp) {
          final currentRanger = await rangerRepo.getRangerById(state!.rangerId);
          if (currentRanger != null) {
            await rangerRepo.updateRangerFields(state!.rangerId, RangersCompanion(
              experiencePoints: Value(currentRanger.experiencePoints + 10),
            ));
          }
        }
      } else {
        final cleanName = tr.name.replaceAll(RegExp(r' \(\d+\)$'), '');
        final match = allEquipment.where((e) => e.name == cleanName).firstOrNull;
        if (match != null) {
          await rangerRepo.insertRangerEquipment(RangerEquipmentCompanion.insert(
            rangerId: state!.rangerId,
            equipmentId: match.id,
            equippedBy: const Value('pool'),
            currentUses: match.hasUses ? Value(match.maxUses) : const Value(null),
          ));
        } else {
          collectedItems.add('${tr.name} (${tr.categoryName})');
        }
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
  }

  Future<void> _stripCloseCallEquipment() async {
    final rangerRepo = _ref.read(rangerRepositoryProvider);
    final hasCloseCall = state!.survivalTargets
        .any((t) => t.result == SurvivalResult.closeCall);
    if (!hasCloseCall) return;

    final equipment = await rangerRepo.getRangerEquipment(state!.rangerId);
    for (final eq in equipment) {
      final eqDef = await rangerRepo.getEquipmentById(eq.equipmentId);
      if (eqDef != null && !eqDef.category.startsWith('basic_')) {
        await rangerRepo.deleteRangerEquipment(eq.id);
      }
    }
  }

  Future<void> _releaseCompanions() async {
    final companionRepo = _ref.read(companionRepositoryProvider);

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
        heroicAbilityKeys: Value(existing.heroicAbilityKeys),
        spellKeys: Value(existing.spellKeys),
      ));
    }
  }

  Future<void> _reactivateCompanions() async {
    final companionRepo = _ref.read(companionRepositoryProvider);

    for (final reactivatedId in state!.reactivatedCompanionIds) {
      final existing = await companionRepo.getCompanionById(reactivatedId);
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
        isActive: const Value(true),
        claimedProgressionRewards: Value(existing.claimedProgressionRewards),
        hasUsedRecruitmentBonus: Value(existing.hasUsedRecruitmentBonus),
        bonusHealth: Value(existing.bonusHealth),
        heroicAbilityKeys: Value(existing.heroicAbilityKeys),
        spellKeys: Value(existing.spellKeys),
      ));
    }
  }

  Future<void> _enrichSessionNotes() async {
    final sessionRepo = _ref.read(sessionRepositoryProvider);

    final buffer = StringBuffer('Treasure Found: ${state!.treasureResults.length}');
    for (final tr in state!.treasureResults) {
      if (tr.category == 'gold') {
        final choice = tr.isGoldChoiceMade
            ? (tr.goldChoseXp ? ', chose +10 XP' : ', chose +1 PP')
            : '';
        buffer.writeln('\n  - Gold and Jewels$choice');
      } else {
        buffer.writeln('\n  - ${tr.categoryName}: ${tr.name}');
      }
    }

    final survivalLines = <String>[];
    for (final target in state!.survivalTargets) {
      if (target.result == null) continue;
      switch (target.result!) {
        case SurvivalResult.dead:
          survivalLines.add('${target.name}: Dead');
        case SurvivalResult.permanentInjury:
          final injuryName = target.injury?.name ?? 'Unknown Injury';
          survivalLines.add('${target.name}: $injuryName');
        case SurvivalResult.badlyWounded:
          survivalLines.add('${target.name}: Badly Wounded');
        case SurvivalResult.closeCall:
          survivalLines.add('${target.name}: Close Call');
        case SurvivalResult.fullRecovery:
          break;
      }
    }
    if (survivalLines.isNotEmpty) {
      buffer.writeln();
      buffer.write('Survival:');
      for (final line in survivalLines) {
        buffer.writeln('\n  - $line');
      }
    }

    await sessionRepo.updateSession(state!.sessionId, SessionsCompanion(
      notes: Value(buffer.toString()),
    ));
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
