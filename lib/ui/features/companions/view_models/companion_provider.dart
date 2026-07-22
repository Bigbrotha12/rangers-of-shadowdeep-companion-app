import 'dart:convert';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/data/repositories/companion_repository_provider.dart';
import 'package:rangers_mobile/domain/constants/companion_types.dart';
import 'package:rangers_mobile/domain/constants/permanent_injuries.dart' show canApplyInjury;
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
  final List<String> claimedProgressionRewards;
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
    this.claimedProgressionRewards = const [],
    this.hasUsedRecruitmentBonus = false,
    this.bonusHealth = 0,
    this.heroicAbilityKeys = const [],
    this.spellKeys = const [],
    this.statusEffects = const [],
  });

  CompanionTypeDefinition? get type => getCompanionType(
    _typeKeyFromId(companionTypeId),
  );

  int get effectiveMove {
    final base = type?.move ?? 6;
    final injuryPenalty = _calculateInjuryPenalty('move');
    return base + injuryPenalty;
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

  String _typeKeyFromId(int id) {
    switch (id) {
      case 1: return 'arcanist';
      case 2: return 'archer';
      case 3: return 'barbarian';
      case 4: return 'conjuror';
      case 5: return 'guardsman';
      case 6: return 'hound';
      case 7: return 'warhound';
      case 8: return 'bloodhound';
      case 9: return 'knight';
      case 10: return 'man_at_arms';
      case 11: return 'raptor';
      case 12: return 'recruit';
      case 13: return 'rogue';
      case 14: return 'savage';
      case 15: return 'swordsman';
      case 16: return 'templar';
      case 17: return 'tracker';
      default: return 'recruit';
    }
  }

  factory CompanionData.fromRow(RangerCompanion row) {
    return CompanionData(
      id: row.id,
      rangerId: row.rangerId,
      companionTypeId: row.companionTypeId,
      customName: row.customName,
      progressionPoints: row.progressionPoints,
      isAlive: row.isAlive,
      permanentInjuries: List<String>.from(
        jsonDecode(row.permanentInjuries) as List? ?? [],
      ),
      customSkills: Map<String, int>.from(
        jsonDecode(row.customSkills) as Map? ?? {},
      ),
      isActive: row.isActive,
      createdAt: row.createdAt,
      claimedProgressionRewards: List<String>.from(
        jsonDecode(row.claimedProgressionRewards) as List? ?? [],
      ),
      hasUsedRecruitmentBonus: row.hasUsedRecruitmentBonus,
      bonusHealth: row.bonusHealth,
      heroicAbilityKeys: List<String>.from(
        jsonDecode(row.heroicAbilityKeys) as List? ?? [],
      ),
      spellKeys: List<String>.from(
        jsonDecode(row.spellKeys) as List? ?? [],
      ),
      statusEffects: List<String>.from(
        jsonDecode(row.statusEffects) as List? ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rangerId': rangerId,
      'companionTypeId': companionTypeId,
      'customName': customName,
      'progressionPoints': progressionPoints,
      'isAlive': isAlive,
      'permanentInjuries': permanentInjuries,
      'customSkills': customSkills,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'claimedProgressionRewards': claimedProgressionRewards,
      'hasUsedRecruitmentBonus': hasUsedRecruitmentBonus,
      'bonusHealth': bonusHealth,
      'heroicAbilityKeys': heroicAbilityKeys,
      'spellKeys': spellKeys,
      'statusEffects': statusEffects,
    };
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
      state = CompanionData.fromRow(row);
    }
  }

  Future<void> updateName(String name) async {
    if (state != null) {
      state = state!.copyWith(customName: name);
      await _persist();
    }
  }

  Future<void> addProgressionPoints(int points) async {
    if (state != null) {
      final newPP = state!.progressionPoints + points;
      state = state!.copyWith(progressionPoints: newPP);
      await _persist();
    }
  }

  Future<void> setProgressionPoints(int newPp) async {
    if (state != null) {
      state = state!.copyWith(progressionPoints: newPp);
      await _persist();
    }
  }

  Future<void> addPermanentInjury(String injuryKey) async {
    if (state != null) {
      if (!canApplyInjury(state!.permanentInjuries, injuryKey)) return;
      final injuries = [...state!.permanentInjuries, injuryKey];
      state = state!.copyWith(permanentInjuries: injuries);
      await _persist();
    }
  }

  Future<void> updateCustomSkill(String skillKey, int value) async {
    if (state != null) {
      final skills = Map<String, int>.from(state!.customSkills);
      skills[skillKey] = value;
      state = state!.copyWith(customSkills: skills);
      await _persist();
    }
  }

  Future<void> addBonusHealth(int amount) async {
    if (state != null) {
      state = state!.copyWith(bonusHealth: state!.bonusHealth + amount);
      await _persist();
    }
  }

  Future<void> markProgressionRewardClaimed(String threshold) async {
    if (state != null) {
      final claimed = [...state!.claimedProgressionRewards, threshold];
      state = state!.copyWith(claimedProgressionRewards: claimed);
      await _persist();
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
      permanentInjuries: Value(jsonEncode(state!.permanentInjuries)),
      customSkills: Value(jsonEncode(state!.customSkills)),
      isActive: Value(state!.isActive),
      claimedProgressionRewards: Value(jsonEncode(state!.claimedProgressionRewards)),
      hasUsedRecruitmentBonus: Value(state!.hasUsedRecruitmentBonus),
      bonusHealth: Value(state!.bonusHealth),
      heroicAbilityKeys: Value(jsonEncode(state!.heroicAbilityKeys)),
      spellKeys: Value(jsonEncode(state!.spellKeys)),
      statusEffects: Value(jsonEncode(state!.statusEffects)),
    ));
    _ref.invalidate(rangerDetailProvider(state!.rangerId));
  }

  Future<void> updateHeroicAbilityKeys(List<String> keys) async {
    if (state != null) {
      state = state!.copyWith(heroicAbilityKeys: keys);
      await _persist();
    }
  }

  Future<void> addSpellKey(String key) async {
    if (state != null) {
      final updated = [...state!.spellKeys, key];
      state = state!.copyWith(spellKeys: updated);
      await _persist();
    }
  }

  Future<void> removeSpellKey(String key) async {
    if (state != null) {
      final updated = [...state!.spellKeys];
      final index = updated.indexOf(key);
      if (index != -1) {
        updated.removeAt(index);
        state = state!.copyWith(spellKeys: updated);
        await _persist();
      }
    }
  }

  Future<void> setSpellKeys(List<String> keys) async {
    if (state != null) {
      state = state!.copyWith(spellKeys: keys);
      await _persist();
    }
  }

  Future<void> addStatusEffect(String effectKey) async {
    if (state == null) return;
    if (state!.statusEffects.contains(effectKey)) return;
    state = state!.copyWith(
      statusEffects: [...state!.statusEffects, effectKey],
    );
    await _persist();
  }

  Future<void> removeStatusEffect(String effectKey) async {
    if (state == null) return;
    state = state!.copyWith(
      statusEffects: state!.statusEffects.where((k) => k != effectKey).toList(),
    );
    await _persist();
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
    List<String>? claimedProgressionRewards,
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
