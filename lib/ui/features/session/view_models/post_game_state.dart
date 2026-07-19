import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/data/services/post_game_service.dart' show SurvivalResult;
import 'package:rangers_mobile/domain/constants/companion_progression.dart' show ProgressionReward;
import 'package:rangers_mobile/domain/constants/experience_table.dart' show LevelBonusType;
import 'package:rangers_mobile/domain/constants/permanent_injuries.dart' show PermanentInjury;

const Object _unset = Object();

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
  final bool goldChoseXp;
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
  final Map<String, int> skillAllocations;
  final int remainingSkillPoints;
  final String? selectedStat;
  final String? selectedHeroicAbility;
  final List<RangerSkill> rangerSkills;
  final List<RangerAbility> rangerAbilities;
  final bool levelUpApplied;
  final Ranger? ranger;

  // Step 2: Companion progression
  final List<CompanionPpState> companionPpGains;

  // Step 3: Treasure
  final int treasureCount;
  final List<TreasureResultState> treasureResults;

  // Step 4: Companions
  final int availableRp;
  final List<CompanionWithType> currentCompanions;
  final Set<int> releasedCompanionIds;
  final Set<int> reactivatedCompanionIds;

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
    this.reactivatedCompanionIds = const {},
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
    Object? bonusType = _unset,
    Map<String, int>? skillAllocations,
    int? remainingSkillPoints,
    Object? selectedStat = _unset,
    Object? selectedHeroicAbility = _unset,
    List<RangerSkill>? rangerSkills,
    List<RangerAbility>? rangerAbilities,
    bool? levelUpApplied,
    Object? ranger = _unset,
    List<CompanionPpState>? companionPpGains,
    int? treasureCount,
    List<TreasureResultState>? treasureResults,
    int? availableRp,
    List<CompanionWithType>? currentCompanions,
    Set<int>? releasedCompanionIds,
    Set<int>? reactivatedCompanionIds,
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
      bonusType: identical(bonusType, _unset) ? this.bonusType : bonusType as LevelBonusType?,
      skillAllocations: skillAllocations ?? this.skillAllocations,
      remainingSkillPoints: remainingSkillPoints ?? this.remainingSkillPoints,
      selectedStat: identical(selectedStat, _unset) ? this.selectedStat : selectedStat as String?,
      selectedHeroicAbility: identical(selectedHeroicAbility, _unset)
          ? this.selectedHeroicAbility
          : selectedHeroicAbility as String?,
      rangerSkills: rangerSkills ?? this.rangerSkills,
      rangerAbilities: rangerAbilities ?? this.rangerAbilities,
      levelUpApplied: levelUpApplied ?? this.levelUpApplied,
      ranger: identical(ranger, _unset) ? this.ranger : ranger as Ranger?,
      companionPpGains: companionPpGains ?? this.companionPpGains,
      treasureCount: treasureCount ?? this.treasureCount,
      treasureResults: treasureResults ?? this.treasureResults,
      availableRp: availableRp ?? this.availableRp,
      currentCompanions: currentCompanions ?? this.currentCompanions,
      releasedCompanionIds: releasedCompanionIds ?? this.releasedCompanionIds,
      reactivatedCompanionIds: reactivatedCompanionIds ?? this.reactivatedCompanionIds,
      isFinalized: isFinalized ?? this.isFinalized,
    );
  }
}
