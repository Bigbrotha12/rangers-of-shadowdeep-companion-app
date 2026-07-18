import 'package:flutter_test/flutter_test.dart';
import 'package:rangers_mobile/domain/constants/base_stats.dart';
import 'package:rangers_mobile/ui/features/rangers/view_models/ranger_creation_provider.dart';

void main() {
  late RangerCreationNotifier notifier;

  setUp(() {
    notifier = RangerCreationNotifier();
  });

  group('initial state', () {
    test('starts at step 0 with empty fields', () {
      expect(notifier.state.currentStep, 0);
      expect(notifier.state.name, '');
      expect(notifier.state.notes, '');
    });

    test('starts with 10 build points and default values', () {
      expect(notifier.state.totalBuildPoints, 10);
      expect(notifier.state.statBonuses, isEmpty);
      expect(notifier.state.selectedHeroicAbilities, isEmpty);
      expect(notifier.state.selectedSpells, isEmpty);
      expect(notifier.state.skillBonuses, isEmpty);
      expect(notifier.state.recruitmentPointsBonus, 0);
      expect(notifier.state.selectedEquipment, isEmpty);
    });
  });

  group('step navigation', () {
    test('nextStep advances from step 0 to step 1', () {
      notifier.nextStep();
      expect(notifier.state.currentStep, 1);
    });

    test('nextStep does not advance past step 3', () {
      notifier.setStep(3);
      notifier.nextStep();
      expect(notifier.state.currentStep, 3);
    });

    test('previousStep goes back', () {
      notifier.setStep(2);
      notifier.previousStep();
      expect(notifier.state.currentStep, 1);
    });

    test('previousStep does not go below step 0', () {
      notifier.previousStep();
      expect(notifier.state.currentStep, 0);
    });
  });

  group('isStep1Valid', () {
    test('empty name is invalid', () {
      expect(notifier.state.isStep1Valid, isFalse);
    });

    test('whitespace-only name is invalid', () {
      notifier.updateName('   ');
      expect(notifier.state.isStep1Valid, isFalse);
    });

    test('non-empty name is valid', () {
      notifier.updateName('Aragorn');
      expect(notifier.state.isStep1Valid, isTrue);
    });
  });

  group('name and notes', () {
    test('updateName changes name', () {
      notifier.updateName('Legolas');
      expect(notifier.state.name, 'Legolas');
    });

    test('updateNotes changes notes', () {
      notifier.updateNotes('Some notes');
      expect(notifier.state.notes, 'Some notes');
    });

    test('updating name preserves other state', () {
      notifier.toggleStatBonus('fight');
      notifier.updateName('Gimli');
      expect(notifier.state.name, 'Gimli');
      expect(notifier.state.statBonuses['fight'], 1);
    });
  });

  group('stat bonuses', () {
    test('toggleStatBonus adds bonus when under max', () {
      final result = notifier.toggleStatBonus('fight');
      expect(result, isTrue);
      expect(notifier.state.statBonuses['fight'], 1);
    });

    test('toggleStatBonus removes existing bonus', () {
      notifier.toggleStatBonus('fight');
      final result = notifier.toggleStatBonus('fight');
      expect(result, isTrue);
      expect(notifier.state.statBonuses, isNot(contains('fight')));
    });

    test('toggleStatBonus returns false when at max 3', () {
      notifier.toggleStatBonus('fight');
      notifier.toggleStatBonus('move');
      notifier.toggleStatBonus('shoot');
      final result = notifier.toggleStatBonus('will');
      expect(result, isFalse);
    });

    test('max 3 stat points total', () {
      expect(maxStatBuildPoints, 3);
    });

    test('statPointsSpent correctly counts', () {
      notifier.toggleStatBonus('fight');
      expect(notifier.state.statPointsSpent, 1);
      notifier.toggleStatBonus('move');
      expect(notifier.state.statPointsSpent, 2);
      notifier.toggleStatBonus('fight'); // remove
      expect(notifier.state.statPointsSpent, 1);
    });
  });

  group('heroic abilities', () {
    test('toggleHeroicAbility adds ability', () {
      final result = notifier.toggleHeroicAbility('dash');
      expect(result, isTrue);
      expect(notifier.state.selectedHeroicAbilities, contains('dash'));
    });

    test('toggleHeroicAbility removes ability', () {
      notifier.toggleHeroicAbility('dash');
      final result = notifier.toggleHeroicAbility('dash');
      expect(result, isTrue);
      expect(notifier.state.selectedHeroicAbilities, isEmpty);
    });

    test('toggleHeroicAbility returns false when at max 5', () {
      for (int i = 0; i < 5; i++) {
        notifier.toggleHeroicAbility('ability_$i');
      }
      final result = notifier.toggleHeroicAbility('extra');
      expect(result, isFalse);
    });

    test('abilityPointsSpent counts both abilities and spells', () {
      notifier.toggleHeroicAbility('dash');
      expect(notifier.state.abilityPointsSpent, 1);
    });

    test('abilities and spells share the same BP pool', () {
      notifier.toggleHeroicAbility('dash');
      // BP pool for abilities = 5 in effectiveMaxAbilities
      // canSpendOnAbilities checks abilityPointsSpent < effectiveMaxAbilities
      expect(notifier.state.abilityPointsSpent, 1);
      expect(notifier.state.remainingBuildPoints, 9);
    });
  });

  group('spells', () {
    test('toggleSpell uses spellKey parameter', () {
      notifier.toggleSpell('heal');
      expect(notifier.state.selectedSpells.containsKey('heal'), isTrue);
    });

    test('toggleSpell adds to selectedSpells not selectedHeroicAbilities', () {
      notifier.toggleSpell('heal');
      expect(notifier.state.selectedHeroicAbilities, isEmpty);
    });

    test('toggleSpell adds a copy when within BP limit', () {
      notifier.toggleSpell('heal');
      expect(notifier.state.selectedSpells.containsKey('heal'), isTrue);
      expect(notifier.state.selectedSpells['heal'], 1);
      notifier.toggleSpell('heal');
      expect(notifier.state.selectedSpells['heal'], 2);
    });

    test('spells and heroic abilities are tracked independently', () {
      notifier.toggleHeroicAbility('dash');
      notifier.toggleSpell('heal');
      expect(notifier.state.selectedHeroicAbilities, contains('dash'));
      expect(notifier.state.selectedSpells.containsKey('heal'), isTrue);
      expect(notifier.state.abilityPointsSpent, 2);
    });

    test('RULEBOOK: same spell can be selected multiple times', () {
      notifier.toggleSpell('heal');
      notifier.toggleSpell('heal');
      expect(
        notifier.state.selectedSpells['heal'],
        greaterThanOrEqualTo(2),
        reason: 'Rulebook §17: same spell should be selectable multiple times',
      );
    });

    test('RULEBOOK: toggle at BP limit removes one copy, not all', () {
      // Fill BP limit with spells (max 5 for abilities+spells combined)
      notifier.toggleSpell('heal');
      notifier.toggleSpell('heal');
      notifier.toggleSpell('heal');
      notifier.toggleSpell('heal');
      notifier.toggleSpell('heal'); // 5 copies, BP pool full
      // Next toggle should remove one copy since canSpendOnAbilities = false
      notifier.toggleSpell('heal');
      expect(
        notifier.state.selectedSpells['heal'],
        4,
        reason: 'Toggling at BP limit should remove only one copy',
      );
    });

    test('RULEBOOK: multiple spell copies deduct 1 BP per copy', () {
      notifier.toggleSpell('heal');
      notifier.toggleSpell('heal');
      expect(notifier.state.abilityPointsSpent, 2,
          reason: 'Two copies of same spell should cost 2 BP');
    });
  });

  group('skill bonuses', () {
    test('updateSkillBonus with delta +1 adds bonus', () {
      final result = notifier.updateSkillBonus('ancient_lore', 1);
      expect(result, isTrue);
      expect(notifier.state.skillBonuses['ancient_lore'], 1);
    });

    test('updateSkillBonus with delta -1 removes bonus', () {
      notifier.updateSkillBonus('ancient_lore', 1);
      notifier.updateSkillBonus('ancient_lore', -1);
      expect(notifier.state.skillBonuses, isNot(contains('ancient_lore')));
    });

    test('updateSkillBonus returns false for negative delta when at 0', () {
      final result = notifier.updateSkillBonus('ancient_lore', -1);
      expect(result, isFalse);
    });

    test('skillPointsSpent formula with 8 skills at +1 returns 1 BP', () {
      for (final key in ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']) {
        notifier.updateSkillBonus(key, 1);
      }
      // 8 skills × +1 = 8 total points, ceil(8/8) = 1, max individual = 1
      // impliedByTotal = 1, impliedByMax = 1
      expect(notifier.state.skillPointsSpent, 1);
    });

    test('skillPointsSpent with 9 points across skills returns 2 BP', () {
      for (final key in ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']) {
        notifier.updateSkillBonus(key, 1);
      }
      notifier.updateSkillBonus('a', 1);
      // 9 total points, ceil(9/8) = 2, max individual = 2
      // impliedByTotal = 2, impliedByMax = 2
      expect(notifier.state.skillPointsSpent, 2);
    });

    test('effectiveMaxSkills limits per-skill bonus', () {
      // With nothing else spent, effectiveMaxSkills = 5
      final result = notifier.updateSkillBonus('ancient_lore', 6);
      expect(result, isFalse);
    });
  });

  group('recruitment points', () {
    test('toggleRecruitmentPoints adds +10 RP', () {
      final result = notifier.toggleRecruitmentPoints();
      expect(result, isTrue);
      expect(notifier.state.recruitmentPointsBonus, 10);
    });

    test('toggleRecruitmentPoints returns false at max 3', () {
      notifier.toggleRecruitmentPoints();
      notifier.toggleRecruitmentPoints();
      notifier.toggleRecruitmentPoints();
      final result = notifier.toggleRecruitmentPoints();
      expect(result, isFalse);
    });

    test('removeRecruitmentPoint subtracts 10', () {
      notifier.toggleRecruitmentPoints();
      notifier.toggleRecruitmentPoints();
      final result = notifier.removeRecruitmentPoint();
      expect(result, isTrue);
      expect(notifier.state.recruitmentPointsBonus, 10);
    });

    test('removeRecruitmentPoint returns false when at 0', () {
      final result = notifier.removeRecruitmentPoint();
      expect(result, isFalse);
    });

    test('totalRecruitmentPoints includes bonus', () {
      notifier.toggleRecruitmentPoints();
      expect(notifier.state.totalRecruitmentPoints, 110);
    });
  });

  group('BP allocation', () {
    test('remainingBuildPoints decreases as points are spent', () {
      expect(notifier.state.remainingBuildPoints, 10);
      notifier.toggleStatBonus('fight');
      expect(notifier.state.remainingBuildPoints, 9);
      notifier.toggleHeroicAbility('dash');
      expect(notifier.state.remainingBuildPoints, 8);
    });

    test('totalSpent sums all categories', () {
      notifier.toggleStatBonus('fight'); // 1
      notifier.toggleHeroicAbility('dash'); // 1
      notifier.toggleRecruitmentPoints(); // 1
      // 1 + 1 + 1 = 3
      expect(notifier.state.totalSpent, 3);
    });

    test('cannot exceed 10 total BP', () {
      // Spend 5 on abilities
      for (int i = 0; i < 5; i++) {
        notifier.toggleHeroicAbility('a_$i');
      }
      // Spend 3 on stats
      notifier.toggleStatBonus('fight');
      notifier.toggleStatBonus('move');
      notifier.toggleStatBonus('shoot');
      // Spend 3 on RP
      notifier.toggleRecruitmentPoints();
      notifier.toggleRecruitmentPoints();
      notifier.toggleRecruitmentPoints();

      // 5 + 3 + 3 = 11 > 10... but some might be capped
      // The individual caps (maxStatBuildPoints=3, maxHeroicAbilityBuildPoints=5,
      // maxRecruitmentPointBuildPoints=3) limit within 10.
      // totalSpent should be ≤ 10.
      expect(notifier.state.totalSpent, lessThanOrEqualTo(10));
    });

    test('refund on removal restores BP', () {
      notifier.toggleStatBonus('fight');
      expect(notifier.state.remainingBuildPoints, 9);
      notifier.toggleStatBonus('fight');
      expect(notifier.state.remainingBuildPoints, 10);
    });

    test('minimal ranger with 0 BP spent is valid', () {
      expect(notifier.state.totalSpent, 0);
      expect(notifier.state.remainingBuildPoints, 10);
      expect(notifier.state.isStep1Valid, isFalse); // name empty
      notifier.updateName('Minimal');
      expect(notifier.state.isStep1Valid, isTrue);
      // 0 BP should be allowed - no minimum spend required
      expect(notifier.state.totalSpent, 0);
    });
  });

  group('equipment', () {
    test('toggleEquipment adds item', () {
      final result = notifier.toggleEquipment('hand_weapon');
      expect(result, isTrue);
      expect(notifier.state.selectedEquipment, contains('hand_weapon'));
    });

    test('toggleEquipment removes existing item', () {
      notifier.toggleEquipment('hand_weapon');
      notifier.toggleEquipment('hand_weapon');
      expect(notifier.state.selectedEquipment, isEmpty);
    });

    test('toggleEquipment returns false at max 5 items', () {
      for (int i = 0; i < 5; i++) {
        notifier.toggleEquipment('item_$i');
      }
      final result = notifier.toggleEquipment('extra');
      expect(result, isFalse);
    });

    test('deselecting all equipment returns to empty', () {
      notifier.toggleEquipment('hand_weapon');
      notifier.toggleEquipment('shield');
      notifier.toggleEquipment('bow');
      expect(notifier.state.selectedEquipment.length, 3);
      notifier.toggleEquipment('hand_weapon');
      notifier.toggleEquipment('shield');
      notifier.toggleEquipment('bow');
      expect(notifier.state.selectedEquipment, isEmpty);
    });
  });

  group('reset', () {
    test('reset restores initial state', () {
      notifier.toggleStatBonus('fight');
      notifier.toggleHeroicAbility('dash');
      notifier.updateName('Test');
      notifier.reset();

      expect(notifier.state.currentStep, 0);
      expect(notifier.state.name, '');
      expect(notifier.state.statBonuses, isEmpty);
      expect(notifier.state.selectedHeroicAbilities, isEmpty);
    });
  });
}
