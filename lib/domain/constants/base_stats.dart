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

/// Build point limits for stat increases
const int maxStatBuildPoints = 3;
const int maxHeroicAbilityBuildPoints = 5;
const int maxSkillBuildPoints = 5;
const int maxRecruitmentPointBuildPoints = 3;

/// Starting base recruitment points
const int startingBaseRecruitmentPoints = 100;

/// Maximum starting equipment items
const int maxStartingEquipmentItems = 5;


