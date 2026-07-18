import 'package:flutter_test/flutter_test.dart';
import 'package:rangers_mobile/domain/constants/status_effects.dart';
import 'package:rangers_mobile/domain/services/stat_calculation_service.dart';

void main() {
  group('StatusEffect model', () {
    test('all predefined effects have unique keys', () {
      final keys = statusEffects.map((e) => e.key).toSet();
      expect(keys.length, statusEffects.length);
    });

    test('getStatusEffect returns correct effect', () {
      final effect = getStatusEffect('poisoned');
      expect(effect, isNotNull);
      expect(effect!.name, 'Poisoned');
      expect(effect.category, StatusEffectCategory.negative);
    });

    test('getStatusEffect returns null for unknown key', () {
      expect(getStatusEffect('unknown'), isNull);
    });

    test('hunger effects stack correctly (1 -> 2 -> 3)', () {
      final h1 = getStatusEffect('hunger_1');
      final h2 = getStatusEffect('hunger_2');
      final h3 = getStatusEffect('hunger_3');
      expect(h1, isNotNull);
      expect(h2, isNotNull);
      expect(h3, isNotNull);
      expect(h1!.statModifiers['health'], -2);
      expect(h2!.statModifiers['health'], -4);
      expect(h3!.statModifiers['health'], -6);
    });

    test('exhausted applies -1 move and -1 will', () {
      final effect = getStatusEffect('exhausted');
      expect(effect, isNotNull);
      expect(effect!.statModifiers['move'], -1);
      expect(effect.statModifiers['will'], -1);
    });

    test('blessed is positive category with +1 will', () {
      final effect = getStatusEffect('blessed');
      expect(effect, isNotNull);
      expect(effect!.category, StatusEffectCategory.positive);
      expect(effect.statModifiers['will'], 1);
    });
  });

  group('computeStatPenalty', () {
    test('returns 0 for no injuries or effects', () {
      final penalty = computeStatPenalty('move',
        permanentInjuryKeys: [],
        statusEffectKeys: [],
      );
      expect(penalty, 0);
    });

    test('combines permanent injury and status effect penalties', () {
      // smashed_leg = -1 move, exhausted = -1 move = total -2
      final penalty = computeStatPenalty('move',
        permanentInjuryKeys: ['smashed_leg'],
        statusEffectKeys: ['exhausted'],
      );
      expect(penalty, -2);
    });

    test('disease applies -1 to all stats', () {
      for (final stat in ['move', 'fight', 'shoot', 'armour', 'will']) {
        expect(computeStatPenalty(stat,
          permanentInjuryKeys: [],
          statusEffectKeys: ['diseased'],
        ), -1);
      }
    });

    test('disease does not affect health', () {
      expect(computeStatPenalty('health',
        permanentInjuryKeys: [],
        statusEffectKeys: ['diseased'],
      ), 0);
    });

    test('hunger_1 applies -2 health', () {
      expect(computeStatPenalty('health',
        permanentInjuryKeys: [],
        statusEffectKeys: ['hunger_1'],
      ), -2);
    });

    test('hunger_2 applies -4 health', () {
      expect(computeStatPenalty('health',
        permanentInjuryKeys: [],
        statusEffectKeys: ['hunger_2'],
      ), -4);
    });

    test('exhausted applies -1 move and -1 will', () {
      expect(computeStatPenalty('move',
        permanentInjuryKeys: [],
        statusEffectKeys: ['exhausted'],
      ), -1);
      expect(computeStatPenalty('will',
        permanentInjuryKeys: [],
        statusEffectKeys: ['exhausted'],
      ), -1);
    });

    test('blessed applies +1 will', () {
      expect(computeStatPenalty('will',
        permanentInjuryKeys: [],
        statusEffectKeys: ['blessed'],
      ), 1);
    });

    test('multiple injuries stack with effects', () {
      // smashed_leg (-1), lost_toes (-1), exhausted (-1) = -3 move
      final penalty = computeStatPenalty('move',
        permanentInjuryKeys: ['smashed_leg', 'lost_toes'],
        statusEffectKeys: ['exhausted'],
      );
      expect(penalty, -3);
    });

    test('never_quite_as_strong stacks with hunger_1 for -3 health', () {
      expect(computeStatPenalty('health',
        permanentInjuryKeys: ['never_quite_as_strong'],
        statusEffectKeys: ['hunger_1'],
      ), -3);
    });

    test('poisoned has no stat modifier penalty', () {
      for (final stat in ['move', 'fight', 'shoot', 'armour', 'will', 'health']) {
        expect(computeStatPenalty(stat,
          permanentInjuryKeys: [],
          statusEffectKeys: ['poisoned'],
        ), 0, reason: 'poison should not affect $stat');
      }
    });

    test('cursed has no stat modifier penalty', () {
      for (final stat in ['move', 'fight', 'shoot', 'armour', 'will', 'health']) {
        expect(computeStatPenalty(stat,
          permanentInjuryKeys: [],
          statusEffectKeys: ['cursed'],
        ), 0, reason: 'cursed should not affect $stat');
      }
    });
  });

  group('getActiveSpecialRules', () {
    test('poison returns max_one_action rule', () {
      final rules = getActiveSpecialRules(
        permanentInjuryKeys: [],
        statusEffectKeys: ['poisoned'],
      );
      expect(rules, contains('max_one_action'));
    });

    test('disease returns next_scenario_health_minus_3 rule', () {
      final rules = getActiveSpecialRules(
        permanentInjuryKeys: [],
        statusEffectKeys: ['diseased'],
      );
      expect(rules, contains('next_scenario_health_minus_3'));
    });

    test('cursed returns varies_by_curse rule', () {
      final rules = getActiveSpecialRules(
        permanentInjuryKeys: [],
        statusEffectKeys: ['cursed'],
      );
      expect(rules, contains('varies_by_curse'));
    });

    test('smashed_jaw returns ranger-specific rules', () {
      final rules = getActiveSpecialRules(
        permanentInjuryKeys: ['smashed_jaw'],
        statusEffectKeys: [],
      );
      expect(rules, contains('max_one_companion_activation'));
      expect(rules, contains('leadership_minus_3'));
    });

    test('lost_eye returns shooting penalty rule', () {
      final rules = getActiveSpecialRules(
        permanentInjuryKeys: ['lost_eye'],
        statusEffectKeys: [],
      );
      expect(rules, contains('fight_minus_1_when_target_of_shooting'));
    });

    test('no effects returns empty list', () {
      final rules = getActiveSpecialRules(
        permanentInjuryKeys: [],
        statusEffectKeys: [],
      );
      expect(rules, isEmpty);
    });
  });

  group('hasMaxOneAction', () {
    test('returns true when poisoned', () {
      expect(hasMaxOneAction(['poisoned']), isTrue);
    });

    test('returns false when not poisoned', () {
      expect(hasMaxOneAction(['exhausted']), isFalse);
      expect(hasMaxOneAction([]), isFalse);
    });

    test('returns false when multiple non-poison effects', () {
      expect(hasMaxOneAction(['diseased', 'exhausted', 'blessed']), isFalse);
    });
  });
}
