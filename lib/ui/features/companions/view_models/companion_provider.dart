import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/data/repositories/companion_repository_provider.dart';
import 'package:rangers_mobile/domain/constants/companion_types.dart';
import 'package:rangers_mobile/domain/services/stat_calculation_service.dart' show computeStatPenalty;
import 'package:rangers_mobile/ui/features/rangers/view_models/ranger_detail_provider.dart';

class CompanionData {
  final int id;
  final int rangerId;
  final int companionTypeId;
  final String customName;
  final int progressionPoints;
  final bool isAlive;
  final List<String> permanentInjuries;
  final Map<String, int> customSkills;
  final bool isActive;
  final DateTime createdAt;
  final Set<int> claimedProgressionRewards;
  final bool hasUsedRecruitmentBonus;
  final int bonusHealth;
  final List<String> heroicAbilityKeys;
  final List<String> spellKeys;
  final List<String> statusEffects;

  CompanionData({
    required this.id,
    required this.rangerId,
    required this.companionTypeId,
    required this.customName,
    this.progressionPoints = 0,
    this.isAlive = true,
    this.permanentInjuries = const [],
    this.customSkills = const {},
    this.isActive = true,
    required this.createdAt,
    this.claimedProgressionRewards = const {},
    this.hasUsedRecruitmentBonus = false,
    this.bonusHealth = 0,
    this.heroicAbilityKeys = const [],
    this.spellKeys = const [],
    this.statusEffects = const [],
  });

  CompanionTypeDefinition? get type => getCompanionType(
    companionTypeKeyFromId(companionTypeId),
  );

  int get effectiveMove {
    final base = type?.move ?? 6;
    final custom = customSkills['move'] ?? 0;
    final injuryPenalty = _calculateInjuryPenalty('move');
    return base + custom + injuryPenalty;
  }

  int get effectiveFight {
    final base = type?.fight ?? 0;
    final custom = customSkills['fight'] ?? 0;
    final injuryPenalty = _calculateInjuryPenalty('fight');
    return base + custom + injuryPenalty;
  }

  int get effectiveShoot {
    final base = type?.shoot ?? 0;
    final custom = customSkills['shoot'] ?? 0;
    final injuryPenalty = _calculateInjuryPenalty('shoot');
    return base + custom + injuryPenalty;
  }

  int get effectiveArmour {
    final base = type?.armour ?? 10;
    return base;
  }

  int get effectiveWill {
    final base = type?.will ?? 0;
    final custom = customSkills['will'] ?? 0;
    final injuryPenalty = _calculateInjuryPenalty('will');
    return base + custom + injuryPenalty;
  }

  int get effectiveHealth {
    final base = type?.health ?? 10;
    final injuryPenalty = _calculateInjuryPenalty('health');
    return base + injuryPenalty + bonusHealth;
  }

  int _calculateInjuryPenalty(String stat) {
    return computeStatPenalty(stat,
      permanentInjuryKeys: permanentInjuries,
      statusEffectKeys: statusEffects,
    );
  }

  factory CompanionData.fromRow(RangerCompanion row) {
    return CompanionData(
      id: row.id,
      rangerId: row.rangerId,
      companionTypeId: row.companionTypeId,
      customName: row.customName,
      progressionPoints: row.progressionPoints,
      isAlive: row.isAlive,
      isActive: row.isActive,
      createdAt: row.createdAt,
      hasUsedRecruitmentBonus: row.hasUsedRecruitmentBonus,
      bonusHealth: row.bonusHealth,
    );
  }
}

final companionProvider = StateNotifierProvider.family<CompanionNotifier, CompanionData?, int>((ref, companionId) {
  return CompanionNotifier(ref, companionId);
});

class CompanionNotifier extends StateNotifier<CompanionData?> {
  CompanionNotifier(this._ref, this.companionId) : super(null) {
    _loadCompanion();
  }

  final Ref _ref;
  final int companionId;

  Future<void> _loadCompanion() async {
    final repo = _ref.read(companionRepositoryProvider);
    final row = await repo.getCompanionById(companionId);
    if (row != null) {
      final injuryKeys = await repo.getCompanionInjuryKeys(companionId);
      final heroicKeys = await repo.getCompanionHeroicAbilityKeys(companionId);
      final spellKeys = await repo.getCompanionSpellKeys(companionId);
      final statusEffectKeys = await repo.getCompanionStatusEffectKeys(companionId);
      final skills = await repo.getCompanionSkills(companionId);
      final claimedThresholds = await repo.getClaimedThresholds(companionId);
      state = CompanionData.fromRow(row).copyWith(
        permanentInjuries: injuryKeys,
        heroicAbilityKeys: heroicKeys,
        spellKeys: spellKeys,
        statusEffects: statusEffectKeys,
        customSkills: skills,
        claimedProgressionRewards: claimedThresholds,
      );
    }
  }

  Future<void> updateName(String name) async {
    if (state != null) {
      state = state!.copyWith(customName: name);
      await _persist();
    }
  }

  Future<void> setProgressionPoints(int newPp) async {
    if (state != null) {
      state = state!.copyWith(progressionPoints: newPp);
      await _persist();
    }
  }

  Future<void> updateCustomSkill(String skillKey, int value) async {
    if (state != null) {
      final repo = _ref.read(companionRepositoryProvider);
      await repo.upsertCompanionSkill(state!.id, skillKey, value);
      final skills = Map<String, int>.from(state!.customSkills);
      skills[skillKey] = value;
      state = state!.copyWith(customSkills: skills);
    }
  }

  Future<void> addBonusHealth(int amount) async {
    if (state != null) {
      state = state!.copyWith(bonusHealth: state!.bonusHealth + amount);
      await _persist();
    }
  }

  Future<void> markProgressionRewardClaimed(int threshold) async {
    if (state != null) {
      if (state!.claimedProgressionRewards.contains(threshold)) return;
      final repo = _ref.read(companionRepositoryProvider);
      await repo.markThresholdClaimed(state!.id, threshold);
      state = state!.copyWith(
        claimedProgressionRewards: {...state!.claimedProgressionRewards, threshold},
      );
      _ref.invalidate(rangerDetailProvider(state!.rangerId));
    }
  }

  Future<void> markRecruitmentBonusUsed() async {
    if (state != null) {
      state = state!.copyWith(hasUsedRecruitmentBonus: true);
      await _persist();
    }
  }

  Future<void> _persist() async {
    if (state == null) return;
    final repo = _ref.read(companionRepositoryProvider);
    await repo.updateCompanion(RangerCompanionsCompanion(
      id: Value(state!.id),
      customName: Value(state!.customName),
      progressionPoints: Value(state!.progressionPoints),
      isAlive: Value(state!.isAlive),
      isActive: Value(state!.isActive),
      hasUsedRecruitmentBonus: Value(state!.hasUsedRecruitmentBonus),
      bonusHealth: Value(state!.bonusHealth),
    ));
    _ref.invalidate(rangerDetailProvider(state!.rangerId));
  }

  Future<void> updateHeroicAbilityKeys(List<String> keys) async {
    if (state != null) {
      final repo = _ref.read(companionRepositoryProvider);
      await repo.setCompanionAbilities(state!.id, state!.rangerId, 'heroic_ability', keys);
      state = state!.copyWith(heroicAbilityKeys: keys);
      _ref.invalidate(rangerDetailProvider(state!.rangerId));
    }
  }

  Future<void> addSpellKey(String key) async {
    if (state != null) {
      final repo = _ref.read(companionRepositoryProvider);
      await repo.addCompanionSpell(state!.id, state!.rangerId, key);
      final updated = [...state!.spellKeys, key];
      state = state!.copyWith(spellKeys: updated);
      _ref.invalidate(rangerDetailProvider(state!.rangerId));
    }
  }

  Future<void> removeSpellKey(String key) async {
    if (state != null) {
      final repo = _ref.read(companionRepositoryProvider);
      await repo.removeCompanionAbilityByIndex(state!.id, key, 'spell');
      final updated = [...state!.spellKeys];
      final index = updated.indexOf(key);
      if (index != -1) {
        updated.removeAt(index);
        state = state!.copyWith(spellKeys: updated);
      }
      _ref.invalidate(rangerDetailProvider(state!.rangerId));
    }
  }

  Future<void> setSpellKeys(List<String> keys) async {
    if (state != null) {
      final repo = _ref.read(companionRepositoryProvider);
      await repo.setCompanionAbilities(state!.id, state!.rangerId, 'spell', keys);
      state = state!.copyWith(spellKeys: keys);
      _ref.invalidate(rangerDetailProvider(state!.rangerId));
    }
  }
}

extension CompanionDataCopy on CompanionData {
  CompanionData copyWith({
    int? id,
    int? rangerId,
    int? companionTypeId,
    String? customName,
    int? progressionPoints,
    bool? isAlive,
    List<String>? permanentInjuries,
    Map<String, int>? customSkills,
    bool? isActive,
    DateTime? createdAt,
    Set<int>? claimedProgressionRewards,
    bool? hasUsedRecruitmentBonus,
    int? bonusHealth,
    List<String>? heroicAbilityKeys,
    List<String>? spellKeys,
    List<String>? statusEffects,
  }) {
    return CompanionData(
      id: id ?? this.id,
      rangerId: rangerId ?? this.rangerId,
      companionTypeId: companionTypeId ?? this.companionTypeId,
      customName: customName ?? this.customName,
      progressionPoints: progressionPoints ?? this.progressionPoints,
      isAlive: isAlive ?? this.isAlive,
      permanentInjuries: permanentInjuries ?? this.permanentInjuries,
      customSkills: customSkills ?? this.customSkills,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      claimedProgressionRewards: claimedProgressionRewards ?? this.claimedProgressionRewards,
      hasUsedRecruitmentBonus: hasUsedRecruitmentBonus ?? this.hasUsedRecruitmentBonus,
      bonusHealth: bonusHealth ?? this.bonusHealth,
      heroicAbilityKeys: heroicAbilityKeys ?? this.heroicAbilityKeys,
      spellKeys: spellKeys ?? this.spellKeys,
      statusEffects: statusEffects ?? this.statusEffects,
    );
  }
}
