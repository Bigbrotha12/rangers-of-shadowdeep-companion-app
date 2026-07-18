import 'package:flutter_test/flutter_test.dart';
import 'package:rangers_mobile/domain/constants/base_stats.dart';

void main() {
  group('RangerBaseStats', () {
    test('default ranger base stats are correct', () {
      expect(rangerBaseStats.move, 6);
      expect(rangerBaseStats.fight, 2);
      expect(rangerBaseStats.shoot, 1);
      expect(rangerBaseStats.armour, 10);
      expect(rangerBaseStats.will, 4);
      expect(rangerBaseStats.health, 18);
    });

    test('startingBuildPoints is 10', () {
      expect(startingBuildPoints, 10);
    });

    test('stat build point limits are correct', () {
      expect(maxStatBuildPoints, 3);
      expect(maxHeroicAbilityBuildPoints, 5);
      expect(maxSkillBuildPoints, 5);
      expect(maxRecruitmentPointBuildPoints, 3);
    });

    test('recruitmentPointsPerBuildPoint is 10', () {
      expect(recruitmentPointsPerBuildPoint, 10);
    });

    test('startingBaseRecruitmentPoints is 100', () {
      expect(startingBaseRecruitmentPoints, 100);
    });

    test('max equipment slots are correct', () {
      expect(maxEquipmentSlots, 6);
      expect(maxStartingEquipmentItems, 5);
    });
  });

  group('RecruitmentCalculation', () {
    test('has 4 entries for player counts 1-4', () {
      expect(recruitmentCalculations.length, 4);
      expect(recruitmentCalculations[0].playerCount, 1);
      expect(recruitmentCalculations[1].playerCount, 2);
      expect(recruitmentCalculations[2].playerCount, 3);
      expect(recruitmentCalculations[3].playerCount, 4);
    });

    test('solo player has max 7 companions', () {
      expect(recruitmentCalculations[0].maxCompanions, 7);
    });

    test('2 players have max 3 companions', () {
      expect(recruitmentCalculations[1].maxCompanions, 3);
    });

    test('3 players have max 2 companions', () {
      expect(recruitmentCalculations[2].maxCompanions, 2);
    });

    test('4 players have max 1 companion', () {
      expect(recruitmentCalculations[3].maxCompanions, 1);
    });
  });

  group('calculateTotalRecruitmentPoints', () {
    test('solo returns base RP unchanged', () {
      expect(calculateTotalRecruitmentPoints(100, 1), 100);
    });

    test('2 players: (BRP x 0.5) - 10', () {
      expect(calculateTotalRecruitmentPoints(100, 2), 40);
    });

    test('3 players: (BRP x 0.3) - 2', () {
      expect(calculateTotalRecruitmentPoints(100, 3), 28);
    });

    test('4 players: BRP x 0.1', () {
      expect(calculateTotalRecruitmentPoints(100, 4), 10);
    });

    test('unknown player count defaults to solo', () {
      expect(calculateTotalRecruitmentPoints(100, 0), 100);
      expect(calculateTotalRecruitmentPoints(100, 5), 100);
    });
  });

  group('getMaxCompanions', () {
    test('returns correct max for 1 player', () {
      expect(getMaxCompanions(1), 7);
    });

    test('returns correct max for 2 players', () {
      expect(getMaxCompanions(2), 3);
    });

    test('returns correct max for 3 players', () {
      expect(getMaxCompanions(3), 2);
    });

    test('returns correct max for 4 players', () {
      expect(getMaxCompanions(4), 1);
    });

    test('defaults to 7 for unknown player count', () {
      expect(getMaxCompanions(0), 7);
      expect(getMaxCompanions(5), 7);
    });
  });

  group('getSurvivalResult', () {
    test('roll 1 returns dead', () {
      expect(getSurvivalResult(1), 'dead');
    });

    test('roll 2 returns dead', () {
      expect(getSurvivalResult(2), 'dead');
    });

    test('roll 3 returns permanent_injury', () {
      expect(getSurvivalResult(3), 'permanent_injury');
    });

    test('roll 4 returns permanent_injury', () {
      expect(getSurvivalResult(4), 'permanent_injury');
    });

    test('roll 5 returns badly_wounded', () {
      expect(getSurvivalResult(5), 'badly_wounded');
    });

    test('roll 6 returns badly_wounded', () {
      expect(getSurvivalResult(6), 'badly_wounded');
    });

    test('roll 7 returns close_call', () {
      expect(getSurvivalResult(7), 'close_call');
    });

    test('roll 8 returns close_call', () {
      expect(getSurvivalResult(8), 'close_call');
    });

    test('roll 9 returns full_recovery', () {
      expect(getSurvivalResult(9), 'full_recovery');
    });

    test('roll 20 returns full_recovery', () {
      expect(getSurvivalResult(20), 'full_recovery');
    });
  });

  group('SwimmingModifiers', () {
    test('has 4 entries', () {
      expect(swimmingModifiers.length, 4);
    });

    test('Light Armour modifier is -2', () {
      expect(
        swimmingModifiers.firstWhere((m) => m.condition == 'Light Armour').modifier,
        -2,
      );
    });

    test('Heavy Armour modifier is -5', () {
      expect(
        swimmingModifiers.firstWhere((m) => m.condition == 'Heavy Armour').modifier,
        -5,
      );
    });

    test('Shield modifier is -1', () {
      expect(
        swimmingModifiers.firstWhere((m) => m.condition == 'Shield').modifier,
        -1,
      );
    });

    test('Carrying Treasure modifier is -2', () {
      expect(
        swimmingModifiers.firstWhere((m) => m.condition == 'Carrying Treasure').modifier,
        -2,
      );
    });
  });

  group('ShootingModifiers', () {
    test('has 5 entries', () {
      expect(shootingModifiers.length, 5);
    });

    test('Intervening Terrain modifier is +1', () {
      final entry = shootingModifiers.firstWhere(
        (m) => m.condition.startsWith('Intervening Terrain'),
      );
      expect(entry.modifier, 1);
    });

    test('Light Cover modifier is +2', () {
      final entry = shootingModifiers.firstWhere(
        (m) => m.condition == 'Light Cover',
      );
      expect(entry.modifier, 2);
    });

    test('Heavy Cover modifier is +4', () {
      final entry = shootingModifiers.firstWhere(
        (m) => m.condition == 'Heavy Cover',
      );
      expect(entry.modifier, 4);
    });

    test('Hurried Shot modifier is +1', () {
      final entry = shootingModifiers.firstWhere(
        (m) => m.condition.startsWith('Hurried Shot'),
      );
      expect(entry.modifier, 1);
    });

    test('Large Target modifier is -2', () {
      final entry = shootingModifiers.firstWhere(
        (m) => m.condition == 'Large Target',
      );
      expect(entry.modifier, -2);
    });
  });
}
