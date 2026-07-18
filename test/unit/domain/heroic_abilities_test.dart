import 'package:flutter_test/flutter_test.dart';
import 'package:rangers_mobile/domain/constants/heroic_abilities.dart';

void main() {
  group('heroicAbilities', () {
    test('has 17 abilities', () {
      expect(heroicAbilities.length, 17);
    });

    test('every ability has a non-empty key', () {
      for (final ability in heroicAbilities) {
        expect(ability.key, isNotEmpty, reason: ability.name);
      }
    });

    test('every ability has a non-empty name', () {
      for (final ability in heroicAbilities) {
        expect(ability.name, isNotEmpty);
      }
    });

    test('every ability has a non-empty description', () {
      for (final ability in heroicAbilities) {
        expect(ability.description, isNotEmpty, reason: ability.name);
      }
    });

    test('every ability has a non-empty whenToUse', () {
      for (final ability in heroicAbilities) {
        expect(ability.whenToUse, isNotEmpty, reason: ability.name);
      }
    });

    test('all expected ability keys are present', () {
      final expectedKeys = {
        'blend_into_shadows',
        'dash',
        'deadly_shot',
        'deadly_strike',
        'distraction',
        'dive_for_cover',
        'evade',
        'focus',
        'frenzied_attack',
        'halt_undead',
        'hand_of_fate',
        'inner_strength',
        'parry',
        'powerful_blow',
        'roll_with_the_punch',
        'shove',
        'steady_aim',
      };
      final actualKeys = heroicAbilities.map((a) => a.key).toSet();
      expect(actualKeys, containsAll(expectedKeys));
      expect(actualKeys.length, 17,
          reason: 'There are 17 unique ability keys (including steady_aim)');
    });

    test('no duplicate keys', () {
      final keys = heroicAbilities.map((a) => a.key).toList();
      expect(keys.toSet().length, keys.length);
    });

    test('Dash has correct key', () {
      final dash = heroicAbilities.firstWhere((a) => a.key == 'dash');
      expect(dash.name, 'Dash');
      expect(dash.whenToUse, 'When the ranger is activated.');
    });

    test('Blend Into the Shadows has correct description', () {
      final ability = heroicAbilities.firstWhere(
        (a) => a.key == 'blend_into_shadows',
      );
      expect(ability.description, contains('as though the ranger'));
    });
  });
}
