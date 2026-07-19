import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/data/repositories/companion_repository_provider.dart';
import 'package:rangers_mobile/domain/constants/permanent_injuries.dart' show canApplyInjury;
import 'package:rangers_mobile/ui/features/companions/view_models/companion_provider.dart';
import '../../helpers/test_database.dart';
import '../../helpers/test_providers.dart';

CompanionData _make({
  int companionTypeId = 12, // Recruit: Move 6, Fight 2, Shoot 0, Armour 10, Will 0, Health 10
  List<String> permanentInjuries = const [],
  Map<String, int> customSkills = const {},
  int bonusHealth = 0,
}) {
  return CompanionData(
    id: 1,
    rangerId: 1,
    companionTypeId: companionTypeId,
    customName: 'Test',
    permanentInjuries: permanentInjuries,
    customSkills: customSkills,
    bonusHealth: bonusHealth,
    createdAt: DateTime.now(),
  );
}

void main() {
  group('effective stats (base)', () {
    test('effectiveFight = base Fight + customSkills fight', () {
      final data = _make(customSkills: {'fight': 2});
      expect(data.effectiveFight, 4); // 2 + 2
    });

    test('effectiveShoot = base Shoot + customSkills shoot', () {
      final data = _make(customSkills: {'shoot': 3});
      expect(data.effectiveShoot, 3); // 0 + 3
    });

    test('effectiveWill = base Will + customSkills will', () {
      final data = _make(customSkills: {'will': 1});
      expect(data.effectiveWill, 1); // 0 + 1
    });

    test('effectiveHealth = base Health + bonusHealth', () {
      final data = _make(bonusHealth: 2);
      expect(data.effectiveHealth, 12); // 10 + 2
    });

    test('effectiveMove = base Move (no customSkills)', () {
      final data = _make();
      expect(data.effectiveMove, 6);
    });

    test('effectiveArmour = base Armour (no modifiers)', () {
      final data = _make();
      expect(data.effectiveArmour, 10);
    });
  });

  group('injury penalties', () {
    test('Lost Toes + Smashed Leg = -2 Move cumulative', () {
      final data = _make(permanentInjuries: ['lost_toes', 'smashed_leg']);
      expect(data.effectiveMove, 4); // 6 - 2
    });

    test('Crushed Arm x2 = -2 Fight cumulative', () {
      final data = _make(permanentInjuries: ['crushed_arm', 'crushed_arm']);
      expect(data.effectiveFight, 0); // 2 - 2
    });

    test('Never Quite as Strong x2 = -2 Health', () {
      final data = _make(permanentInjuries: [
        'never_quite_as_strong',
        'never_quite_as_strong',
      ]);
      expect(data.effectiveHealth, 8); // 10 - 2
    });

    test('Lost Fingers = -1 Shoot', () {
      final data = _make(permanentInjuries: ['lost_fingers']);
      expect(data.effectiveShoot, -1); // 0 - 1
    });

    test('Psychological Scars = -1 Will', () {
      final data = _make(permanentInjuries: ['psychological_scars']);
      expect(data.effectiveWill, -1); // 0 - 1
    });
  });

  group('special injuries with no stat effect', () {
    test('Lost Eye does NOT affect effectiveFight', () {
      final data = _make(permanentInjuries: ['lost_eye']);
      expect(data.effectiveFight, 2);
    });

    test('Lost Eye does NOT affect effectiveShoot', () {
      final data = _make(permanentInjuries: ['lost_eye']);
      expect(data.effectiveShoot, 0);
    });

    test('Lost Eye does NOT affect effectiveMove', () {
      final data = _make(permanentInjuries: ['lost_eye']);
      expect(data.effectiveMove, 6);
    });

    test('Lost Eye does NOT affect effectiveHealth', () {
      final data = _make(permanentInjuries: ['lost_eye']);
      expect(data.effectiveHealth, 10);
    });

    test('Lost Eye does NOT affect effectiveWill', () {
      final data = _make(permanentInjuries: ['lost_eye']);
      expect(data.effectiveWill, 0);
    });

    test('Smashed Jaw does NOT affect any effective stat', () {
      final data = _make(permanentInjuries: ['smashed_jaw']);
      expect(data.effectiveFight, 2);
      expect(data.effectiveShoot, 0);
      expect(data.effectiveMove, 6);
      expect(data.effectiveHealth, 10);
      expect(data.effectiveWill, 0);
    });
  });

  group('maxTimesReceived enforcement', () {
    group('canApplyInjury', () {
      test('Crushed Arm maxTimesReceived=2 rejects third occurrence', () {
        final injuries = ['crushed_arm', 'crushed_arm'];
        expect(canApplyInjury(injuries, 'crushed_arm'), isFalse);
      });

      test('Crushed Arm allows second occurrence', () {
        final injuries = ['crushed_arm'];
        expect(canApplyInjury(injuries, 'crushed_arm'), isTrue);
      });

      test('Crushed Arm allows first occurrence', () {
        final injuries = <String>[];
        expect(canApplyInjury(injuries, 'crushed_arm'), isTrue);
      });

      test('Smashed Jaw maxTimesReceived=1 rejects second occurrence', () {
        final injuries = ['smashed_jaw'];
        expect(canApplyInjury(injuries, 'smashed_jaw'), isFalse);
      });

      test('Smashed Jaw allows first occurrence', () {
        final injuries = <String>[];
        expect(canApplyInjury(injuries, 'smashed_jaw'), isTrue);
      });

      test('unknown injury uses default maxTimesReceived=2', () {
        final injuries = ['unknown_injury', 'unknown_injury'];
        expect(canApplyInjury(injuries, 'unknown_injury'), isFalse);
      });

      test('empty injuries allows any injury', () {
        expect(canApplyInjury([], 'crushed_arm'), isTrue);
      });
    });

    group('CompanionNotifier.addPermanentInjury', () {
      late AppDatabase database;
      late ProviderContainer container;

      setUp(() async {
        SharedPreferences.setMockInitialValues({});
        database = await createTestDatabase();
        final prefs = await SharedPreferences.getInstance();
        container = ProviderContainer(overrides: buildTestOverrides(
          database: database,
          sharedPreferences: prefs,
        ));
        final repo = container.read(companionRepositoryProvider);
        await repo.insertCompanion(RangerCompanionsCompanion.insert(
          rangerId: 1,
          companionTypeId: 12,
          customName: 'Test',
          createdAt: DateTime.now(),
        ));
      });

      tearDown(() {
        container.dispose();
        database.close();
      });

      test('rejects injury when maxTimesReceived reached', () async {
        final notifier = container.read(companionProvider(1).notifier);
        await Future(() {}); // let _loadCompanion complete

        await notifier.addPermanentInjury('crushed_arm');
        await notifier.addPermanentInjury('crushed_arm');
        await notifier.addPermanentInjury('crushed_arm'); // should be rejected

        expect(notifier.state, isNotNull);
        expect(
          notifier.state!.permanentInjuries.where((k) => k == 'crushed_arm').length,
          2,
        );
      });

      test('allows injury within maxTimesReceived', () async {
        final notifier = container.read(companionProvider(1).notifier);
        await Future(() {}); // let _loadCompanion complete

        await notifier.addPermanentInjury('crushed_arm');
        expect(
          notifier.state!.permanentInjuries.where((k) => k == 'crushed_arm').length,
          1,
        );
      });
    });
  });

  group('type getter', () {
    test('returns correct CompanionType from companionTypeId', () {
      final data = _make(); // Recruit
      expect(data.type, isNotNull);
      expect(data.type!.name, 'Recruit');
    });

    test('unknown companionTypeId defaults to Recruit', () {
      final data = _make(companionTypeId: 999);
      expect(data.type, isNotNull);
      expect(data.type!.name, 'Recruit');
    });
  });
}
