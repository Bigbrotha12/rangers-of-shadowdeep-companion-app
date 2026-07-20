import 'package:flutter_test/flutter_test.dart';
import 'package:rangers_mobile/domain/constants/creatures.dart';

void main() {
  group('creatures', () {
    test('has 30 creatures', () {
      expect(creatures.length, 30);
    });

    test('every creature has a non-empty key', () {
      for (final creature in creatures) {
        expect(creature.key, isNotEmpty, reason: creature.name);
      }
    });

    test('every creature has a non-empty name', () {
      for (final creature in creatures) {
        expect(creature.name, isNotEmpty);
      }
    });

    test('every creature has a non-empty description', () {
      for (final creature in creatures) {
        expect(creature.description, isNotEmpty, reason: creature.name);
      }
    });

    test('every creature has non-negative stats', () {
      for (final creature in creatures) {
        expect(creature.move, greaterThanOrEqualTo(0), reason: creature.name);
        expect(creature.fight, greaterThanOrEqualTo(0), reason: creature.name);
        expect(creature.shoot, greaterThanOrEqualTo(0), reason: creature.name);
        expect(creature.armour, greaterThanOrEqualTo(0), reason: creature.name);
        expect(creature.will, greaterThanOrEqualTo(0), reason: creature.name);
        expect(creature.health, greaterThanOrEqualTo(0), reason: creature.name);
      }
    });

    test('every creature has non-negative xpValue', () {
      for (final creature in creatures) {
        expect(creature.xpValue, greaterThanOrEqualTo(0), reason: creature.name);
      }
    });

    test('no duplicate keys', () {
      final keys = creatures.map((c) => c.key).toList();
      expect(keys.toSet().length, keys.length);
    });

    test('all expected creature keys are present', () {
      final expectedKeys = {
        'blood_bat',
        'burrow_worm',
        'civilian',
        'darkroot_body',
        'darkroot_vine',
        'flesh_golem',
        'giant_fly',
        'giant_rat',
        'giant_spider',
        'ghoul',
        'ghoul_fiend',
        'ghoul_flinger',
        'ghoul_rotter',
        'ghoul_snake',
        'giant_snake',
        'gnoll_fighter',
        'gnoll_archer',
        'gnoll_sergeant',
        'gnoll_shaman',
        'ogre',
        'shadow_knight',
        'skeletal_knight',
        'skeleton',
        'swamp_zombie',
        'terror_wing',
        'tortured_soul',
        'troll',
        'vulture',
        'wolf',
        'zombie',
      };
      final actualKeys = creatures.map((c) => c.key).toSet();
      expect(actualKeys, containsAll(expectedKeys));
      expect(actualKeys.length, 30);
    });

    test('Blood Bat has correct stats', () {
      final bat = creatures.firstWhere((c) => c.key == 'blood_bat');
      expect(bat.name, 'Blood Bat');
      expect(bat.xpValue, 1);
      expect(bat.move, 8);
      expect(bat.fight, 1);
      expect(bat.shoot, 0);
      expect(bat.armour, 12);
      expect(bat.will, 3);
      expect(bat.health, 1);
      expect(bat.notes, 'Animal, Flying');
    });

    test('Terror Wing has highest XP', () {
      final terror = creatures.firstWhere((c) => c.key == 'terror_wing');
      expect(terror.xpValue, 20);
    });

    test('Troll has special rules', () {
      final troll = creatures.firstWhere((c) => c.key == 'troll');
      expect(troll.specialRules, isNotEmpty);
      expect(troll.specialRules.any((r) => r.contains('Two-Headed')), isTrue);
    });

    test('darkroot variants have variant labels', () {
      final body = creatures.firstWhere((c) => c.key == 'darkroot_body');
      final vine = creatures.firstWhere((c) => c.key == 'darkroot_vine');
      expect(body.variantLabel, 'Body');
      expect(vine.variantLabel, 'Vine');
    });
  });

  group('getCreature', () {
    test('returns correct creature by key', () {
      final zombie = getCreature('zombie');
      expect(zombie, isNotNull);
      expect(zombie!.name, 'Zombie');
      expect(zombie.move, 4);
      expect(zombie.health, 6);
    });

    test('returns null for unknown key', () {
      expect(getCreature('nonexistent_slug'), isNull);
    });
  });

  group('searchCreatures', () {
    test('returns all creatures for empty query', () {
      expect(searchCreatures('').length, 30);
    });

    test('finds by name (full match)', () {
      final results = searchCreatures('Ghoul');
      expect(results, isNotEmpty);
      expect(results.every((c) => c.name.contains('Ghoul')), isTrue);
    });

    test('finds by name (partial match)', () {
      final results = searchCreatures('Giant');
      expect(results, isNotEmpty);
      expect(results.every((c) => c.name.contains('Giant')), isTrue);
    });

    test('finds by notes', () {
      final results = searchCreatures('Flying');
      expect(results, isNotEmpty);
      expect(results.any((c) => c.key == 'blood_bat'), isTrue);
      expect(results.any((c) => c.key == 'giant_fly'), isTrue);
    });

    test('is case-insensitive', () {
      final upper = searchCreatures('ZOMBIE');
      final lower = searchCreatures('zombie');
      expect(upper.length, lower.length);
      expect(upper.any((c) => c.name == 'Zombie'), isTrue);
    });
  });
}
