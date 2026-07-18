import 'package:flutter_test/flutter_test.dart';
import 'package:rangers_mobile/domain/constants/treasure_table.dart';

void main() {
  group('treasureTable (main table)', () {
    test('has 4 entries', () {
      expect(treasureTable.length, 4);
    });

    test('roll 1-6 maps to Gold and Jewels', () {
      expect(treasureTable[0].name, 'Gold and Jewels');
      expect(treasureTable[0].minRoll, 1);
      expect(treasureTable[0].maxRoll, 6);
    });

    test('roll 7-12 maps to Herb or Potion', () {
      expect(treasureTable[1].name, 'Herb or Potion');
      expect(treasureTable[1].minRoll, 7);
      expect(treasureTable[1].maxRoll, 12);
    });

    test('roll 13-16 maps to Weapon or Armour', () {
      expect(treasureTable[2].name, 'Weapon or Armour');
      expect(treasureTable[2].minRoll, 13);
      expect(treasureTable[2].maxRoll, 16);
    });

    test('roll 17-20 maps to Magic Item', () {
      expect(treasureTable[3].name, 'Magic Item');
      expect(treasureTable[3].minRoll, 17);
      expect(treasureTable[3].maxRoll, 20);
    });
  });

  group('herbsPotionsTable', () {
    test('has 20 entries (one per d20 roll)', () {
      expect(herbsPotionsTable.length, 20);
    });

    test('each entry covers exactly one roll', () {
      for (final entry in herbsPotionsTable) {
        expect(entry.minRoll, entry.maxRoll,
            reason: '${entry.name} should cover exactly one roll');
      }
    });

    test('all roll values 1-20 are covered', () {
      final covered = <int>{};
      for (final entry in herbsPotionsTable) {
        covered.addAll([entry.minRoll, entry.maxRoll]);
      }
      for (int i = 1; i <= 20; i++) {
        expect(covered, contains(i), reason: 'Roll $i should be covered');
      }
    });
  });

  group('weaponsArmourTable', () {
    test('has 20 entries (one per d20 roll)', () {
      expect(weaponsArmourTable.length, 20);
    });

    test('each entry covers exactly one roll', () {
      for (final entry in weaponsArmourTable) {
        expect(entry.minRoll, entry.maxRoll,
            reason: '${entry.name} should cover exactly one roll');
      }
    });

    test('all roll values 1-20 are covered', () {
      final covered = <int>{};
      for (final entry in weaponsArmourTable) {
        covered.addAll([entry.minRoll, entry.maxRoll]);
      }
      for (int i = 1; i <= 20; i++) {
        expect(covered, contains(i), reason: 'Roll $i should be covered');
      }
    });
  });

  group('magicItemsTable', () {
    test('has 20 entries (one per d20 roll)', () {
      expect(magicItemsTable.length, 20);
    });

    test('each entry covers exactly one roll', () {
      for (final entry in magicItemsTable) {
        expect(entry.minRoll, entry.maxRoll,
            reason: '${entry.name} should cover exactly one roll');
      }
    });

    test('all roll values 1-20 are covered', () {
      final covered = <int>{};
      for (final entry in magicItemsTable) {
        covered.addAll([entry.minRoll, entry.maxRoll]);
      }
      for (int i = 1; i <= 20; i++) {
        expect(covered, contains(i), reason: 'Roll $i should be covered');
      }
    });
  });

  group('lookupTreasure', () {
    test('returns entry for valid roll', () {
      final result = lookupTreasure(treasureTable, 1);
      expect(result, isNotNull);
      expect(result!.name, 'Gold and Jewels');
    });

    test('returns null for out-of-range roll', () {
      expect(lookupTreasure(treasureTable, 0), isNull);
      expect(lookupTreasure(treasureTable, 21), isNull);
    });

    test('boundary: roll 6 returns Gold', () {
      final result = lookupTreasure(treasureTable, 6);
      expect(result!.name, 'Gold and Jewels');
    });

    test('boundary: roll 7 returns Herb or Potion', () {
      final result = lookupTreasure(treasureTable, 7);
      expect(result!.name, 'Herb or Potion');
    });

    test('boundary: roll 12 returns Herb or Potion', () {
      final result = lookupTreasure(treasureTable, 12);
      expect(result!.name, 'Herb or Potion');
    });

    test('boundary: roll 13 returns Weapon or Armour', () {
      final result = lookupTreasure(treasureTable, 13);
      expect(result!.name, 'Weapon or Armour');
    });

    test('lookupTreasure on herbsPotionsTable returns correct item', () {
      final result = lookupTreasure(herbsPotionsTable, 11);
      expect(result!.name, 'Potion of Healing');
    });

    test('lookupTreasure on magicItemsTable returns correct item', () {
      final result = lookupTreasure(magicItemsTable, 8);
      expect(result!.name, 'Amulet of Leadership');
    });
  });

  group('resolveTreasureRoll', () {
    test('gold roll returns Gold category', () {
      final result = resolveTreasureRoll(1, 0);
      expect(result.name, 'Gold and Jewels');
      expect(result.category, 'gold');
    });

    test('herb roll resolves through sub-table', () {
      final result = resolveTreasureRoll(7, 11);
      expect(result.name, 'Potion of Healing');
      expect(result.category, 'herb_potion');
    });

    test('weapon roll resolves through sub-table', () {
      final result = resolveTreasureRoll(13, 2);
      expect(result.name, 'Two-Handed Weapon, Magic (5)');
    });

    test('magic item roll resolves through sub-table', () {
      final result = resolveTreasureRoll(17, 6);
      expect(result.name, 'Greyleaf Cloak');
    });

    test('unknown main roll returns Unknown', () {
      final result = resolveTreasureRoll(0, 0);
      expect(result.name, 'Unknown');
      expect(result.category, 'unknown');
    });

    test('unknown sub-roll returns fallback name', () {
      final result = resolveTreasureRoll(7, 0);
      expect(result.name, 'Unknown Herb');
    });
  });
}
