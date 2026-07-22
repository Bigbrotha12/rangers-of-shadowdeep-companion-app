/// Experience point cost for each ranger level
/// Level 0 is the starting level
class LevelCost {
  const LevelCost({
    required this.minLevel,
    required this.maxLevel,
    required this.xpCost,
  });

  final int minLevel;
  final int maxLevel;
  final int xpCost;
}

const List<LevelCost> levelCosts = [
  LevelCost(minLevel: 1, maxLevel: 5, xpCost: 100),
  LevelCost(minLevel: 6, maxLevel: 10, xpCost: 150),
  LevelCost(minLevel: 11, maxLevel: 15, xpCost: 200),
  LevelCost(minLevel: 16, maxLevel: 20, xpCost: 250),
  LevelCost(minLevel: 21, maxLevel: 30, xpCost: 300),
  LevelCost(minLevel: 31, maxLevel: 40, xpCost: 400),
  LevelCost(minLevel: 41, maxLevel: 50, xpCost: 500),
  LevelCost(minLevel: 51, maxLevel: 100, xpCost: 1000),
];

/// Maximum experience points a ranger can accumulate
const int maxExperiencePoints = 99999;

/// Get the XP cost to advance to the next level
int getXpCostForLevel(int currentLevel) {
  final nextLevel = currentLevel + 1;
  for (final cost in levelCosts) {
    if (nextLevel >= cost.minLevel && nextLevel <= cost.maxLevel) {
      return cost.xpCost;
    }
  }
  // Beyond level 100, use the last tier
  return 1000;
}

/// Level bonus types
enum LevelBonusType {
  improveSkills,
  improveStats,
  gainRecruitmentPoints,
  newHeroicAbilityOrSpell,
}

/// Get the bonus type for a given level
LevelBonusType getLevelBonusType(int newLevel) {
  // Pattern repeats every 4 levels starting from level 1
  final position = newLevel % 4;
  switch (position) {
    case 1:
      return LevelBonusType.improveSkills;
    case 2:
      return LevelBonusType.improveStats;
    case 3:
      return LevelBonusType.gainRecruitmentPoints;
    case 0: // position 0 = level 4, 8, 12, etc.
      return LevelBonusType.newHeroicAbilityOrSpell;
    default:
      return LevelBonusType.improveSkills;
  }
}

/// Stat improvement limits when leveling up
class StatImprovementLimit {
  const StatImprovementLimit({
    required this.stat,
    required this.maxValue,
  });

  final String stat;
  final int maxValue;
}

const List<StatImprovementLimit> statImprovementLimits = [
  StatImprovementLimit(stat: 'move', maxValue: 7),
  StatImprovementLimit(stat: 'fight', maxValue: 5),
  StatImprovementLimit(stat: 'shoot', maxValue: 5),
  StatImprovementLimit(stat: 'will', maxValue: 8),
  StatImprovementLimit(stat: 'health', maxValue: 22),
];

/// Get the maximum allowed value for a stat
int getStatMaxValue(String stat) {
  for (final limit in statImprovementLimits) {
    if (limit.stat == stat) {
      return limit.maxValue;
    }
  }
  return 99; // No limit for unknown stats
}


