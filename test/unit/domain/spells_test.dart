import 'package:flutter_test/flutter_test.dart';
import 'package:rangers_mobile/domain/constants/spells.dart';

void main() {
  group('spells', () {
    test('has 10 spells', () {
      expect(spells.length, 10);
    });

    test('every spell has a non-empty key', () {
      for (final spell in spells) {
        expect(spell.key, isNotEmpty, reason: spell.name);
      }
    });

    test('every spell has a non-empty name', () {
      for (final spell in spells) {
        expect(spell.name, isNotEmpty);
      }
    });

    test('every spell has a non-empty description', () {
      for (final spell in spells) {
        expect(spell.description, isNotEmpty, reason: spell.name);
      }
    });

    test('every spell has a non-empty targetType', () {
      for (final spell in spells) {
        expect(spell.targetType, isNotEmpty, reason: spell.name);
      }
    });

    test('all expected spell keys are present', () {
      final expectedKeys = {
        'burning_light',
        'burning_mark',
        'enchanted_steel',
        'heal',
        'hold_creature',
        'magic_bolt',
        'shield_of_light',
        'smoke',
        'strong_heart',
        'translate',
      };
      final actualKeys = spells.map((s) => s.key).toSet();
      expect(actualKeys, expectedKeys);
    });

    test('no duplicate keys', () {
      final keys = spells.map((s) => s.key).toList();
      expect(keys.toSet().length, keys.length);
    });

    test('hold_creature has willRollTn of 16', () {
      final spell = spells.firstWhere((s) => s.key == 'hold_creature');
      expect(spell.willRollTn, 16);
    });

    test('heal has null willRollTn', () {
      final spell = spells.firstWhere((s) => s.key == 'heal');
      expect(spell.willRollTn, isNull);
    });

    test('smoke has null willRollTn', () {
      final spell = spells.firstWhere((s) => s.key == 'smoke');
      expect(spell.willRollTn, isNull);
    });

    test('translate targetType is self', () {
      final spell = spells.firstWhere((s) => s.key == 'translate');
      expect(spell.targetType, 'self');
    });

    test('burning_light targetType is area', () {
      final spell = spells.firstWhere((s) => s.key == 'burning_light');
      expect(spell.targetType, 'area');
    });

    test('heal targetType is single_figure', () {
      final spell = spells.firstWhere((s) => s.key == 'heal');
      expect(spell.targetType, 'single_figure');
    });
  });
}
