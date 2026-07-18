import 'package:flutter_test/flutter_test.dart';
import 'package:rangers_mobile/domain/constants/experience_table.dart';

void main() {
  group('levelCosts', () {
    test('has 8 tiers spanning levels 1-100', () {
      expect(levelCosts.length, 8);
      expect(levelCosts.first.minLevel, 1);
      expect(levelCosts.last.maxLevel, 100);
    });

    test('levels 1-5 cost 100 XP', () {
      expect(levelCosts[0].xpCost, 100);
    });

    test('levels 6-10 cost 150 XP', () {
      expect(levelCosts[1].xpCost, 150);
    });

    test('levels 11-15 cost 200 XP', () {
      expect(levelCosts[2].xpCost, 200);
    });

    test('levels 16-20 cost 250 XP', () {
      expect(levelCosts[3].xpCost, 250);
    });

    test('levels 21-30 cost 300 XP', () {
      expect(levelCosts[4].xpCost, 300);
    });

    test('levels 31-40 cost 400 XP', () {
      expect(levelCosts[5].xpCost, 400);
    });

    test('levels 41-50 cost 500 XP', () {
      expect(levelCosts[6].xpCost, 500);
    });

    test('levels 51-100 cost 1000 XP', () {
      expect(levelCosts[7].xpCost, 1000);
    });
  });

  group('getXpCostForLevel', () {
    test('level 0 costs 100 XP (next is level 1)', () {
      expect(getXpCostForLevel(0), 100);
    });

    test('level 4 costs 100 XP (next is level 5)', () {
      expect(getXpCostForLevel(4), 100);
    });

    test('level 5 costs 150 XP (next is level 6)', () {
      expect(getXpCostForLevel(5), 150);
    });

    test('level 10 costs 200 XP (next is level 11)', () {
      expect(getXpCostForLevel(10), 200);
    });

    test('level 15 costs 250 XP (next is level 16)', () {
      expect(getXpCostForLevel(15), 250);
    });

    test('level 20 costs 300 XP (next is level 21)', () {
      expect(getXpCostForLevel(20), 300);
    });

    test('level 30 costs 400 XP (next is level 31)', () {
      expect(getXpCostForLevel(30), 400);
    });

    test('level 40 costs 500 XP (next is level 41)', () {
      expect(getXpCostForLevel(40), 500);
    });

    test('level 50 costs 1000 XP (next is level 51)', () {
      expect(getXpCostForLevel(50), 1000);
    });

    test('level 100 costs 1000 XP (beyond max tier)', () {
      expect(getXpCostForLevel(100), 1000);
    });
  });

  group('LevelBonusType', () {
    test('level 1 returns improveSkills', () {
      expect(getLevelBonusType(1), LevelBonusType.improveSkills);
    });

    test('level 2 returns improveStats', () {
      expect(getLevelBonusType(2), LevelBonusType.improveStats);
    });

    test('level 3 returns gainRecruitmentPoints', () {
      expect(getLevelBonusType(3), LevelBonusType.gainRecruitmentPoints);
    });

    test('level 4 returns newHeroicAbilityOrSpell', () {
      expect(getLevelBonusType(4), LevelBonusType.newHeroicAbilityOrSpell);
    });

    test('level 5 repeats the improveSkills pattern', () {
      expect(getLevelBonusType(5), LevelBonusType.improveSkills);
    });

    test('level 6 repeats the improveStats pattern', () {
      expect(getLevelBonusType(6), LevelBonusType.improveStats);
    });

    test('level 8 repeats the newHeroicAbilityOrSpell pattern', () {
      expect(getLevelBonusType(8), LevelBonusType.newHeroicAbilityOrSpell);
    });
  });

  group('statImprovementLimits', () {
    test('has 5 stat entries', () {
      expect(statImprovementLimits.length, 5);
    });

    test('move max is 7', () {
      final entry = statImprovementLimits.firstWhere((s) => s.stat == 'move');
      expect(entry.maxValue, 7);
    });

    test('fight max is 5', () {
      final entry = statImprovementLimits.firstWhere((s) => s.stat == 'fight');
      expect(entry.maxValue, 5);
    });

    test('shoot max is 5', () {
      final entry = statImprovementLimits.firstWhere((s) => s.stat == 'shoot');
      expect(entry.maxValue, 5);
    });

    test('will max is 8', () {
      final entry = statImprovementLimits.firstWhere((s) => s.stat == 'will');
      expect(entry.maxValue, 8);
    });

    test('health max is 22', () {
      final entry = statImprovementLimits.firstWhere((s) => s.stat == 'health');
      expect(entry.maxValue, 22);
    });
  });

  group('getStatMaxValue', () {
    test('returns correct max for move', () {
      expect(getStatMaxValue('move'), 7);
    });

    test('returns correct max for fight', () {
      expect(getStatMaxValue('fight'), 5);
    });

    test('returns correct max for shoot', () {
      expect(getStatMaxValue('shoot'), 5);
    });

    test('returns correct max for will', () {
      expect(getStatMaxValue('will'), 8);
    });

    test('returns correct max for health', () {
      expect(getStatMaxValue('health'), 22);
    });

    test('returns 99 for unknown stat', () {
      expect(getStatMaxValue('unknown'), 99);
    });
  });

  group('xpRewards', () {
    test('has 7 XP reward entries', () {
      expect(xpRewards.length, 7);
    });

    test('kill_monster rewards 5 XP', () {
      final entry = xpRewards.firstWhere((r) => r.key == 'kill_monster');
      expect(entry.xp, 5);
    });

    test('kill_leader rewards 10 XP', () {
      final entry = xpRewards.firstWhere((r) => r.key == 'kill_leader');
      expect(entry.xp, 10);
    });

    test('rescue_prisoner rewards 15 XP', () {
      final entry = xpRewards.firstWhere((r) => r.key == 'rescue_prisoner');
      expect(entry.xp, 15);
    });

    test('discover_info rewards 10 XP', () {
      final entry = xpRewards.firstWhere((r) => r.key == 'discover_info');
      expect(entry.xp, 10);
    });

    test('use_skill rewards 5 XP', () {
      final entry = xpRewards.firstWhere((r) => r.key == 'use_skill');
      expect(entry.xp, 5);
    });

    test('complete_objective rewards 20 XP', () {
      final entry = xpRewards.firstWhere((r) => r.key == 'complete_objective');
      expect(entry.xp, 20);
    });

    test('gold_for_xp rewards 10 XP', () {
      final entry = xpRewards.firstWhere((r) => r.key == 'gold_for_xp');
      expect(entry.xp, 10);
    });
  });
}
