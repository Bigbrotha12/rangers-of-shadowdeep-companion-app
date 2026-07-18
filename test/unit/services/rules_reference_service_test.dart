import 'package:flutter_test/flutter_test.dart';
import 'package:rangers_mobile/data/services/rules_reference_service.dart';

void main() {
  late RulesReferenceService service;

  setUp(() {
    service = RulesReferenceService();
  });

  group('allEntries', () {
    test('returns all entries', () {
      final entries = service.allEntries;
      expect(entries.length, greaterThan(0));
    });

    test('total count across all categories is 163', () {
      final total = service.allEntries.length;
      // 17 abilities + 10 spells + 15 skills + 17 companions
      // + 12 basic equipment + 40 magic items + 20 herbs/potions
      // + 8 injuries + 8 status effects + 11 treasure table entries + 5 quick reference = 163
      expect(total, 163);
    });
  });

  group('getEntriesByCategory', () {
    test('heroic_abilities has 17 entries', () {
      expect(service.getEntriesByCategory('heroic_abilities').length, 17);
    });

    test('spells has 10 entries', () {
      expect(service.getEntriesByCategory('spells').length, 10);
    });

    test('skills has 15 entries', () {
      expect(service.getEntriesByCategory('skills').length, 15);
    });

    test('companions has 17 entries', () {
      expect(service.getEntriesByCategory('companions').length, 17);
    });

    test('basic_equipment has 12 entries', () {
      expect(service.getEntriesByCategory('basic_equipment').length, 12);
    });

    test('magic_items has 40 entries', () {
      expect(service.getEntriesByCategory('magic_items').length, 40);
    });

    test('herbs_potions has 20 entries', () {
      expect(service.getEntriesByCategory('herbs_potions').length, 20);
    });

    test('permanent_injuries has 8 entries', () {
      expect(service.getEntriesByCategory('permanent_injuries').length, 8);
    });

    test('status_effects has 8 entries', () {
      expect(service.getEntriesByCategory('status_effects').length, 8);
    });

    test('treasure_tables has 11 entries', () {
      expect(service.getEntriesByCategory('treasure_tables').length, 11);
    });

    test('quick_reference has 5 entries', () {
      expect(service.getEntriesByCategory('quick_reference').length, 5);
    });

    test('empty list for unknown category', () {
      expect(service.getEntriesByCategory('nonexistent'), isEmpty);
    });
  });

  group('getEntryById', () {
    test('returns correct heroic ability', () {
      final entry = service.getEntryById('heroic_abilities', 'dash');
      expect(entry, isNotNull);
      expect(entry!.title, 'Dash');
    });

    test('returns correct spell', () {
      final entry = service.getEntryById('spells', 'heal');
      expect(entry, isNotNull);
      expect(entry!.title, 'Heal');
    });

    test('returns correct companion', () {
      final entry = service.getEntryById('companions', 'arcanist');
      expect(entry, isNotNull);
      expect(entry!.title, 'Arcanist');
    });

    test('returns null for unknown entry', () {
      expect(service.getEntryById('heroic_abilities', 'nonexistent'), isNull);
    });

    test('returns null for unknown category', () {
      expect(service.getEntryById('nonexistent', 'dash'), isNull);
    });
  });

  group('search', () {
    test('empty query returns empty list', () {
      expect(service.search(''), isEmpty);
    });

    test('finds by title', () {
      final results = service.search('Dash');
      expect(results, isNotEmpty);
      expect(results.any((e) => e.title == 'Dash'), isTrue);
    });

    test('finds by description', () {
      final results = service.search('heal');
      expect(results, isNotEmpty);
      expect(results.any((e) => e.category == 'spells'), isTrue);
    });

    test('finds by metadata values', () {
      final results = service.search('when the ranger is activated');
      expect(results, isNotEmpty);
    });

    test('is case-insensitive', () {
      final upper = service.search('DASH');
      final lower = service.search('dash');
      expect(upper.length, lower.length);
    });

    test('finds quick reference entries', () {
      final results = service.search('Combat Modifiers');
      expect(results, isNotEmpty);
    });
  });

  group('categoryCount', () {
    test('heroic_abilities count is 17', () {
      expect(service.categoryCount('heroic_abilities'), 17);
    });

    test('spells count is 10', () {
      expect(service.categoryCount('spells'), 10);
    });

    test('companions count is 17', () {
      expect(service.categoryCount('companions'), 17);
    });

    test('magic_items count is 40', () {
      expect(service.categoryCount('magic_items'), 40);
    });

    test('unknown category returns 0', () {
      expect(service.categoryCount('nonexistent'), 0);
    });
  });

  group('referenceCategories', () {
    test('has 10 categories', () {
      expect(referenceCategories.length, 10);
    });

    test('includes heroic_abilities', () {
      expect(referenceCategories.any((c) => c.key == 'heroic_abilities'), isTrue);
    });

    test('includes spells', () {
      expect(referenceCategories.any((c) => c.key == 'spells'), isTrue);
    });
  });

  group('quickReferenceEntries', () {
    test('has 5 entries', () {
      expect(quickReferenceEntries.length, 5);
    });

    test('includes combat_modifiers', () {
      expect(quickReferenceEntries.any((e) => e.id == 'combat_modifiers'), isTrue);
    });

    test('includes creature_ai', () {
      expect(quickReferenceEntries.any((e) => e.id == 'creature_ai'), isTrue);
    });
  });
}
