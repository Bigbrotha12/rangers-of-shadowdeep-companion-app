import 'package:flutter_test/flutter_test.dart';
import 'package:rangers_mobile/data/services/post_game_service.dart';
import 'package:rangers_mobile/domain/constants/experience_table.dart';
import 'package:rangers_mobile/domain/constants/permanent_injuries.dart';

void main() {
  group('rollSurvivalTable', () {
    test('roll 1 with non-ranger returns dead', () {
      expect(
        rollSurvivalTable(1, isRanger: false),
        SurvivalResult.dead,
      );
    });

    test('roll 2 with non-ranger returns dead', () {
      expect(
        rollSurvivalTable(2, isRanger: false),
        SurvivalResult.dead,
      );
    });

    test('roll 1 with ranger (modified to 2) returns dead', () {
      expect(rollSurvivalTable(1, isRanger: true), SurvivalResult.dead);
    });

    test('roll 3 with non-ranger returns permanentInjury', () {
      expect(
        rollSurvivalTable(3, isRanger: false),
        SurvivalResult.permanentInjury,
      );
    });

    test('roll 3 with ranger (modified to 4) returns permanentInjury', () {
      expect(
        rollSurvivalTable(3, isRanger: true),
        SurvivalResult.permanentInjury,
      );
    });

    test('roll 5 with non-ranger returns badlyWounded', () {
      expect(
        rollSurvivalTable(5, isRanger: false),
        SurvivalResult.badlyWounded,
      );
    });

    test('roll 5 with ranger (modified to 6) returns badlyWounded', () {
      expect(
        rollSurvivalTable(5, isRanger: true),
        SurvivalResult.badlyWounded,
      );
    });

    test('roll 7 with non-ranger returns closeCall', () {
      expect(
        rollSurvivalTable(7, isRanger: false),
        SurvivalResult.closeCall,
      );
    });

    test('roll 7 with ranger (modified to 8) returns closeCall', () {
      expect(
        rollSurvivalTable(7, isRanger: true),
        SurvivalResult.closeCall,
      );
    });

    test('roll 8 with ranger (modified to 9) returns fullRecovery', () {
      expect(
        rollSurvivalTable(8, isRanger: true),
        SurvivalResult.fullRecovery,
      );
    });

    test('roll 9 with non-ranger returns fullRecovery', () {
      expect(
        rollSurvivalTable(9, isRanger: false),
        SurvivalResult.fullRecovery,
      );
    });

    test('roll 20 with ranger returns fullRecovery', () {
      expect(
        rollSurvivalTable(20, isRanger: true),
        SurvivalResult.fullRecovery,
      );
    });
  });

  group('rollInjuryTableWithRoll', () {
    test('d20 1 returns Lost Toes', () {
      final injury = rollInjuryTableWithRoll(1);
      expect(injury.key, 'lost_toes');
    });

    test('d20 4 returns Smashed Leg', () {
      final injury = rollInjuryTableWithRoll(4);
      expect(injury.key, 'smashed_leg');
    });

    test('d20 6 returns Crushed Arm', () {
      final injury = rollInjuryTableWithRoll(6);
      expect(injury.key, 'crushed_arm');
    });

    test('d20 11 returns Lost Fingers', () {
      final injury = rollInjuryTableWithRoll(11);
      expect(injury.key, 'lost_fingers');
    });

    test('d20 13 returns Never Quite as Strong', () {
      final injury = rollInjuryTableWithRoll(13);
      expect(injury.key, 'never_quite_as_strong');
    });

    test('d20 15 returns Psychological Scars', () {
      final injury = rollInjuryTableWithRoll(15);
      expect(injury.key, 'psychological_scars');
    });

    test('d20 17 returns Smashed Jaw', () {
      final injury = rollInjuryTableWithRoll(17);
      expect(injury.key, 'smashed_jaw');
    });

    test('d20 19 returns Lost Eye', () {
      final injury = rollInjuryTableWithRoll(19);
      expect(injury.key, 'lost_eye');
    });

    test('d20 20 returns Lost Eye', () {
      final injury = rollInjuryTableWithRoll(20);
      expect(injury.key, 'lost_eye');
    });

    test('every d20 1-20 returns a valid injury', () {
      for (int d20 = 1; d20 <= 20; d20++) {
        final injury = rollInjuryTableWithRoll(d20);
        expect(
          permanentInjuries.any((i) => i.key == injury.key),
          isTrue,
          reason: 'd20 $d20 should map to a valid injury key',
        );
      }
    });
  });

  group('rollTreasureWithRolls', () {
    test('main=1 returns Gold and Jewels', () {
      final result = rollTreasureWithRolls(1, 0);
      expect(result.name, 'Gold and Jewels');
    });

    test('main=7 sub=11 returns Potion of Healing', () {
      final result = rollTreasureWithRolls(7, 11);
      expect(result.name, 'Potion of Healing');
    });

    test('main=13 sub=2 returns Two-Handed Weapon, Magic (5)', () {
      final result = rollTreasureWithRolls(13, 2);
      expect(result.name, 'Two-Handed Weapon, Magic (5)');
    });

    test('main=17 sub=8 returns Amulet of Leadership', () {
      final result = rollTreasureWithRolls(17, 8);
      expect(result.name, 'Amulet of Leadership');
    });
  });

  group('calculateLevel', () {
    test('0 XP is level 0', () {
      expect(calculateLevel(0), 0);
    });

    test('99 XP is level 0', () {
      expect(calculateLevel(99), 0);
    });

    test('100 XP is level 1', () {
      expect(calculateLevel(100), 1);
    });

    test('200 XP (100+100) is level 2', () {
      expect(calculateLevel(200), 2);
    });

    test('500 XP (100+100+100+100+100) is level 5', () {
      expect(calculateLevel(500), 5);
    });

    test('4050 XP is level 21', () {
      expect(calculateLevel(4050), 21);
    });

    test('6500 XP is level 30', () {
      expect(calculateLevel(6500), 30);
    });
  });

  group('xpCostForLevel', () {
    test('level 0 costs 100 XP', () {
      expect(xpCostForLevel(0), 100);
    });

    test('level 4 costs 100 XP', () {
      expect(xpCostForLevel(4), 100);
    });

    test('level 5 costs 150 XP', () {
      expect(xpCostForLevel(5), 150);
    });

    test('level 50 costs 1000 XP', () {
      expect(xpCostForLevel(50), 1000);
    });
  });

  group('bonusTypeForLevel', () {
    test('level 1 returns improveSkills', () {
      expect(bonusTypeForLevel(1), LevelBonusType.improveSkills);
    });

    test('level 2 returns improveStats', () {
      expect(bonusTypeForLevel(2), LevelBonusType.improveStats);
    });

    test('level 3 returns gainRecruitmentPoints', () {
      expect(bonusTypeForLevel(3), LevelBonusType.gainRecruitmentPoints);
    });

    test('level 4 returns newHeroicAbilityOrSpell', () {
      expect(bonusTypeForLevel(4), LevelBonusType.newHeroicAbilityOrSpell);
    });
  });

  group('SurvivalTarget', () {
    test('constructs correctly', () {
      final target = SurvivalTarget(id: 1, name: 'Test', isRanger: true);
      expect(target.id, 1);
      expect(target.name, 'Test');
      expect(target.isRanger, isTrue);
    });

    test('can be non-ranger', () {
      final target = SurvivalTarget(id: 2, name: 'Companion', isRanger: false);
      expect(target.isRanger, isFalse);
    });
  });
}
