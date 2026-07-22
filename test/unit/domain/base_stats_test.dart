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

    test('stat build point limits are correct', () {
      expect(maxStatBuildPoints, 3);
      expect(maxHeroicAbilityBuildPoints, 5);
      expect(maxSkillBuildPoints, 5);
      expect(maxRecruitmentPointBuildPoints, 3);
    });

    test('startingBaseRecruitmentPoints is 100', () {
      expect(startingBaseRecruitmentPoints, 100);
    });

    test('maxStartingEquipmentItems is 5', () {
      expect(maxStartingEquipmentItems, 5);
    });
  });

}
