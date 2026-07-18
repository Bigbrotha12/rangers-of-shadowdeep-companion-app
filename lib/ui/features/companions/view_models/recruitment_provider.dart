import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/database/app_database.dart' hide CompanionType;
import '../../../../data/repositories/companion_repository_provider.dart';
import '../../../../domain/constants/companion_types.dart'
    show CompanionType, companionTypeKeyFromId;

class RecruitmentState {
  final int rangerId;
  final int baseRecruitmentPoints;
  final int leadershipBonus;
  final int playerCount;
  final List<CompanionEntry> currentCompanions;

  const RecruitmentState({
    required this.rangerId,
    this.baseRecruitmentPoints = 100,
    this.leadershipBonus = 0,
    this.playerCount = 1,
    this.currentCompanions = const [],
  });

  int get totalRecruitmentPoints {
    switch (playerCount) {
      case 1:
        return baseRecruitmentPoints + leadershipBonus;
      case 2:
        return ((baseRecruitmentPoints * 0.5) - 10).round() + leadershipBonus;
      case 3:
        return ((baseRecruitmentPoints * 0.3) - 2).round() + leadershipBonus;
      case 4:
        return (baseRecruitmentPoints * 0.1).round() + leadershipBonus;
      default:
        return baseRecruitmentPoints + leadershipBonus;
    }
  }

  int get spentRecruitmentPoints {
    return currentCompanions.fold(0, (sum, c) => sum + c.effectiveRpCost);
  }

  int get availableRecruitmentPoints {
    return totalRecruitmentPoints - spentRecruitmentPoints;
  }

  int get maxCompanions {
    switch (playerCount) {
      case 1: return 7;
      case 2: return 3;
      case 3: return 2;
      case 4: return 1;
      default: return 7;
    }
  }

  bool get canAddMoreCompanions {
    return currentCompanions.length < maxCompanions;
  }

  bool canRecruit(CompanionType type) {
    return canAddMoreCompanions && availableRecruitmentPoints >= type.rpCost;
  }
}

class CompanionEntry {
  final int companionTypeId;
  final String name;
  final int rpCost;
  final int? existingId;
  final bool hasPurchasedThirdSpell;

  const CompanionEntry({
    required this.companionTypeId,
    required this.name,
    required this.rpCost,
    this.existingId,
    this.hasPurchasedThirdSpell = false,
  });

  String get key => companionTypeKeyFromId(companionTypeId);

  int get effectiveRpCost {
    if (key == 'conjuror' && hasPurchasedThirdSpell) {
      return rpCost + 10;
    }
    return rpCost;
  }
}

final recruitmentProvider = StateNotifierProvider.family<RecruitmentNotifier, RecruitmentState, int>((ref, rangerId) {
  return RecruitmentNotifier(ref, rangerId);
});

class RecruitmentNotifier extends StateNotifier<RecruitmentState> {
  RecruitmentNotifier(this._ref, int rangerId) : super(RecruitmentState(rangerId: rangerId)) {
    _loadRecruitmentData();
  }

  final Ref _ref;

  Future<void> _loadRecruitmentData() async {
    final repo = _ref.read(companionRepositoryProvider);
    final companionRows = await repo.getCompanionsByRanger(state.rangerId);
    
    final companions = <CompanionEntry>[];
    for (final row in companionRows) {
      // Look up type name from companion_types table
      final typeData = await repo.getCompanionTypeById(row.companionTypeId);
      companions.add(CompanionEntry(
        companionTypeId: row.companionTypeId,
        name: typeData?.name ?? 'Unknown',
        rpCost: typeData?.rpCost ?? 0,
        existingId: row.id,
      ));
    }

    state = RecruitmentState(
      rangerId: state.rangerId,
      baseRecruitmentPoints: state.baseRecruitmentPoints,
      leadershipBonus: state.leadershipBonus,
      playerCount: state.playerCount,
      currentCompanions: companions,
    );
  }

  void setBaseRecruitmentPoints(int brp) {
    state = RecruitmentState(
      rangerId: state.rangerId,
      baseRecruitmentPoints: brp,
      leadershipBonus: state.leadershipBonus,
      playerCount: state.playerCount,
      currentCompanions: state.currentCompanions,
    );
  }

  void setLeadershipBonus(int bonus) {
    state = RecruitmentState(
      rangerId: state.rangerId,
      baseRecruitmentPoints: state.baseRecruitmentPoints,
      leadershipBonus: bonus,
      playerCount: state.playerCount,
      currentCompanions: state.currentCompanions,
    );
  }

  void setPlayerCount(int count) {
    state = RecruitmentState(
      rangerId: state.rangerId,
      baseRecruitmentPoints: state.baseRecruitmentPoints,
      leadershipBonus: state.leadershipBonus,
      playerCount: count.clamp(1, 4),
      currentCompanions: state.currentCompanions,
    );
  }

  bool recruitCompanion(CompanionType type) {
    if (!state.canRecruit(type)) return false;

    final entry = CompanionEntry(
      companionTypeId: _typeKeyToId(type.key),
      name: type.name,
      rpCost: type.rpCost,
      hasPurchasedThirdSpell: type.key == 'conjuror' ? false : false,
    );

    state = RecruitmentState(
      rangerId: state.rangerId,
      baseRecruitmentPoints: state.baseRecruitmentPoints,
      leadershipBonus: state.leadershipBonus,
      playerCount: state.playerCount,
      currentCompanions: [...state.currentCompanions, entry],
    );

    return true;
  }

  void toggleThirdSpell(int index) {
    if (index < 0 || index >= state.currentCompanions.length) return;
    final entry = state.currentCompanions[index];
    if (entry.key != 'conjuror') return;

    // If turning on, check there's enough RP
    if (!entry.hasPurchasedThirdSpell && state.availableRecruitmentPoints < 10) return;

    final updated = CompanionEntry(
      companionTypeId: entry.companionTypeId,
      name: entry.name,
      rpCost: entry.rpCost,
      existingId: entry.existingId,
      hasPurchasedThirdSpell: !entry.hasPurchasedThirdSpell,
    );

    final companions = List<CompanionEntry>.from(state.currentCompanions);
    companions[index] = updated;

    state = RecruitmentState(
      rangerId: state.rangerId,
      baseRecruitmentPoints: state.baseRecruitmentPoints,
      leadershipBonus: state.leadershipBonus,
      playerCount: state.playerCount,
      currentCompanions: companions,
    );
  }

  void removeCompanion(int index) {
    if (index < 0 || index >= state.currentCompanions.length) return;

    final companions = List<CompanionEntry>.from(state.currentCompanions);
    companions.removeAt(index);

    state = RecruitmentState(
      rangerId: state.rangerId,
      baseRecruitmentPoints: state.baseRecruitmentPoints,
      leadershipBonus: state.leadershipBonus,
      playerCount: state.playerCount,
      currentCompanions: companions,
    );
  }

  Future<void> saveCompanions() async {
    final repo = _ref.read(companionRepositoryProvider);
    
    // Delete all existing companions for this ranger
    final existing = await repo.getCompanionsByRanger(state.rangerId);
    for (final row in existing) {
      await repo.deleteCompanion(row.id);
    }

    // Insert all current companions
    for (final entry in state.currentCompanions) {
      await repo.insertCompanion(RangerCompanionsCompanion(
        rangerId: Value(state.rangerId),
        companionTypeId: Value(entry.companionTypeId),
        customName: Value(entry.name),
        progressionPoints: const Value(0),
        isAlive: const Value(true),
        permanentInjuries: const Value('[]'),
        customSkills: const Value('{}'),
        isActive: const Value(true),
        createdAt: Value(DateTime.now()),
        claimedProgressionRewards: const Value('[]'),
        hasUsedRecruitmentBonus: const Value(false),
        bonusHealth: const Value(0),
      ));
    }
  }

  int _typeKeyToId(String key) {
    switch (key) {
      case 'arcanist': return 1;
      case 'archer': return 2;
      case 'barbarian': return 3;
      case 'conjuror': return 4;
      case 'guardsman': return 5;
      case 'hound': return 6;
      case 'warhound': return 7;
      case 'bloodhound': return 8;
      case 'knight': return 9;
      case 'man_at_arms': return 10;
      case 'raptor': return 11;
      case 'recruit': return 12;
      case 'rogue': return 13;
      case 'savage': return 14;
      case 'swordsman': return 15;
      case 'templar': return 16;
      case 'tracker': return 17;
      default: return 12;
    }
  }
}
