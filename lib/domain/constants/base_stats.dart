/// Ranger base stat-line at creation
class RangerBaseStats {
  const RangerBaseStats({
    required this.move,
    required this.fight,
    required this.shoot,
    required this.armour,
    required this.will,
    required this.health,
  });

  final int move;
  final int fight;
  final int shoot;
  final int armour;
  final int will;
  final int health;
}

const RangerBaseStats rangerBaseStats = RangerBaseStats(
  move: 6,
  fight: 2,
  shoot: 1,
  armour: 10,
  will: 4,
  health: 18,
);

/// Starting build points
const int startingBuildPoints = 10;

/// Build point limits for stat increases
const int maxStatBuildPoints = 3;
const int maxHeroicAbilityBuildPoints = 5;
const int maxSkillBuildPoints = 5;
const int maxRecruitmentPointBuildPoints = 3;

/// Recruitment point increase per build point
const int recruitmentPointsPerBuildPoint = 10;

/// Starting base recruitment points
const int startingBaseRecruitmentPoints = 100;

/// Maximum equipment slots for a ranger
const int maxEquipmentSlots = 6;

/// Maximum starting equipment items
const int maxStartingEquipmentItems = 5;

/// Recruitment point calculations based on player count
class RecruitmentCalculation {
  const RecruitmentCalculation({
    required this.playerCount,
    required this.formula,
    required this.maxCompanions,
  });

  final int playerCount;
  final String formula;
  final int maxCompanions;
}

const List<RecruitmentCalculation> recruitmentCalculations = [
  RecruitmentCalculation(
    playerCount: 1,
    formula: 'BRP',
    maxCompanions: 7,
  ),
  RecruitmentCalculation(
    playerCount: 2,
    formula: '(BRP x 0.5) - 10',
    maxCompanions: 3,
  ),
  RecruitmentCalculation(
    playerCount: 3,
    formula: '(BRP x 0.3) - 2',
    maxCompanions: 2,
  ),
  RecruitmentCalculation(
    playerCount: 4,
    formula: '(BRP x 0.1)',
    maxCompanions: 1,
  ),
];

/// Calculate total recruitment points based on player count
int calculateTotalRecruitmentPoints(int baseRP, int playerCount) {
  switch (playerCount) {
    case 1:
      return baseRP;
    case 2:
      return ((baseRP * 0.5) - 10).round();
    case 3:
      return ((baseRP * 0.3) - 2).round();
    case 4:
      return (baseRP * 0.1).round();
    default:
      return baseRP;
  }
}

/// Get max companions for a player count
int getMaxCompanions(int playerCount) {
  for (final calc in recruitmentCalculations) {
    if (calc.playerCount == playerCount) {
      return calc.maxCompanions;
    }
  }
  return 7; // Default to solo
}

/// Survival Table for injury/death checks
String getSurvivalResult(int d20) {
  if (d20 <= 2) return 'dead';
  if (d20 <= 4) return 'permanent_injury';
  if (d20 <= 6) return 'badly_wounded';
  if (d20 <= 8) return 'close_call';
  return 'full_recovery';
}

/// Swimming modifiers
class SwimmingModifier {
  const SwimmingModifier({
    required this.condition,
    required this.modifier,
  });

  final String condition;
  final int modifier;
}

const List<SwimmingModifier> swimmingModifiers = [
  SwimmingModifier(condition: 'Light Armour', modifier: -2),
  SwimmingModifier(condition: 'Heavy Armour', modifier: -5),
  SwimmingModifier(condition: 'Shield', modifier: -1),
  SwimmingModifier(condition: 'Carrying Treasure', modifier: -2),
];

/// Shooting modifiers
class ShootingModifier {
  const ShootingModifier({
    required this.modifier,
    required this.condition,
  });

  final int modifier;
  final String condition;
}

const List<ShootingModifier> shootingModifiers = [
  ShootingModifier(modifier: 1, condition: 'Intervening Terrain (per piece)'),
  ShootingModifier(modifier: 2, condition: 'Light Cover'),
  ShootingModifier(modifier: 4, condition: 'Heavy Cover'),
  ShootingModifier(modifier: 1, condition: 'Hurried Shot (shooter moved)'),
  ShootingModifier(modifier: -2, condition: 'Large Target'),
];
