import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/data/repositories/companion_repository_provider.dart';
import 'package:rangers_mobile/data/repositories/ranger_repository_provider.dart';
import 'package:rangers_mobile/data/repositories/session_repository_provider.dart';
import 'package:rangers_mobile/data/services/post_game_service.dart';
import 'package:rangers_mobile/domain/constants/experience_table.dart';
import 'package:rangers_mobile/ui/features/session/view_models/post_game_provider.dart';
import 'package:rangers_mobile/ui/features/session/view_models/post_game_state.dart';
import '../../fixtures/ranger_data.dart';
import '../../helpers/test_database.dart';
import '../../helpers/test_providers.dart';

void main() {
  group('PostGameState', () {
    PostGameState createState({
      int step = 0,
      int sessionId = 1,
      int rangerId = 1,
      String rangerName = 'Hero',
    }) {
      return PostGameState(
        sessionId: sessionId,
        rangerId: rangerId,
        rangerName: rangerName,
      );
    }

    test('default state has step 0', () {
      final state = createState();
      expect(state.currentStep, 0);
    });

    test('copyWith updates fields', () {
      final state = createState().copyWith(currentStep: 2);
      expect(state.currentStep, 2);
      expect(state.rangerName, 'Hero');
    });

    test('didLevelUp is false by default', () {
      final state = createState();
      expect(state.didLevelUp, isFalse);
    });

    test('isFinalized is false by default', () {
      final state = createState();
      expect(state.isFinalized, isFalse);
    });

    test('survivalTargets is empty by default', () {
      final state = createState();
      expect(state.survivalTargets, isEmpty);
    });

    test('treasureResults is empty by default', () {
      final state = createState();
      expect(state.treasureResults, isEmpty);
    });
  });

  group('PostGameNotifier', () {
    late PostGameNotifier notifier;
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(postGameProvider.notifier);
      notifier.state = const PostGameState(
        sessionId: 1,
        rangerId: 1,
        rangerName: 'Hero',
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('navigation', () {
      test('goToStep changes step', () {
        notifier.goToStep(2);
        expect(notifier.state!.currentStep, 2);
      });

      test('nextStep increments step', () {
        notifier.nextStep();
        expect(notifier.state!.currentStep, 1);
      });

      test('goToStep is no-op when state is null', () {
        notifier.state = null;
        notifier.goToStep(2);
        expect(notifier.state, isNull);
      });
    });

    group('survival', () {
      test('rollSurvival sets roll and modifies for ranger (+1)', () {
        notifier.state = notifier.state!.copyWith(
          survivalTargets: [
            const SurvivalTargetState(id: 1, name: 'Hero', isRanger: true),
          ],
        );
        notifier.rollSurvival(1, isRanger: true, predeterminedRoll: 5);
        final target = notifier.state!.survivalTargets.first;
        expect(target.survivalRoll, 5);
        expect(target.survivalRollModified, 6);
        expect(target.result, SurvivalResult.badlyWounded);
      });

      test('rollSurvival for non-ranger does not add +1 modifier', () {
        notifier.state = notifier.state!.copyWith(
          survivalTargets: [
            const SurvivalTargetState(id: 2, name: 'Dog', isRanger: false),
          ],
        );
        notifier.rollSurvival(2, isRanger: false, predeterminedRoll: 5);
        final target = notifier.state!.survivalTargets.first;
        expect(target.survivalRoll, 5);
        expect(target.survivalRollModified, 5);
      });

      test('rollSurvival for dead on roll 1', () {
        notifier.state = notifier.state!.copyWith(
          survivalTargets: [
            const SurvivalTargetState(id: 1, name: 'Hero', isRanger: true),
          ],
        );
        notifier.rollSurvival(1, isRanger: true, predeterminedRoll: 1);
        expect(
          notifier.state!.survivalTargets.first.result,
          SurvivalResult.dead,
        );
      });

      test('rollInjury only allowed when result is permanentInjury', () {
        notifier.state = notifier.state!.copyWith(
          survivalTargets: [
            const SurvivalTargetState(
              id: 1, name: 'Hero', isRanger: true,
              result: SurvivalResult.permanentInjury,
            ),
          ],
        );
        notifier.rollInjuryWithValue(1, 1, isRanger: true);
        expect(
          notifier.state!.survivalTargets.first.injury!.key,
          'lost_toes',
        );
      });

      test('rollInjury with wrong result is no-op', () {
        notifier.state = notifier.state!.copyWith(
          survivalTargets: [
            const SurvivalTargetState(
              id: 1, name: 'Hero', isRanger: true,
              result: SurvivalResult.fullRecovery,
            ),
          ],
        );
        notifier.rollInjury(1, isRanger: true);
        expect(notifier.state!.survivalTargets.first.injuryRoll, isNull);
      });
    });

    group('XP and level up', () {
      setUp(() {
        notifier.state = notifier.state!.copyWith(
          didLevelUp: true,
          bonusType: LevelBonusType.improveSkills,
          remainingSkillPoints: 5,
          oldXp: 100,
          newXp: 200,
          oldLevel: 1,
          newLevel: 2,
        );
      });

      test('setSkillAllocation deducts remaining points', () {
        notifier.setSkillAllocation('ancient_lore', 2);
        expect(notifier.state!.skillAllocations['ancient_lore'], 2);
        expect(notifier.state!.remainingSkillPoints, 3);
      });

      test('setSkillAllocation caps at 2 per skill', () {
        notifier.setSkillAllocation('ancient_lore', 3);
        expect(notifier.state!.skillAllocations['ancient_lore'], 2);
      });

      test('setSkillAllocation removes allocation when set to 0', () {
        notifier.setSkillAllocation('ancient_lore', 2);
        notifier.setSkillAllocation('ancient_lore', -2);
        expect(
          notifier.state!.skillAllocations,
          isNot(contains('ancient_lore')),
        );
      });

      test('setSkillAllocation caps at 2 even when requesting more than remaining', () {
        notifier.setSkillAllocation('ancient_lore', 6);
        expect(notifier.state!.skillAllocations['ancient_lore'], 2);
      });

      test('selectStat toggles stat selection', () {
        notifier.selectStat('fight');
        expect(notifier.state!.selectedStat, 'fight');
        notifier.selectStat('fight');
        expect(notifier.state!.selectedStat, isNull);
      });

      test('selectHeroicAbility toggles ability selection', () {
        notifier.selectHeroicAbility('dash');
        expect(notifier.state!.selectedHeroicAbility, 'dash');
        notifier.selectHeroicAbility('dash');
        expect(notifier.state!.selectedHeroicAbility, isNull);
      });

      test('applyLevelUp blocked when skill points remain', () {
        notifier.applyLevelUp();
        expect(notifier.state!.levelUpApplied, isFalse);
      });

      test('applyLevelUp succeeds when all skill points allocated', () {
        container = ProviderContainer();
        notifier = container.read(postGameProvider.notifier);
        notifier.state = const PostGameState(
          sessionId: 1, rangerId: 1, rangerName: 'Hero',
          didLevelUp: true,
          bonusType: LevelBonusType.improveStats,
          selectedStat: 'fight',
        );
        notifier.applyLevelUp();
        expect(notifier.state!.levelUpApplied, isTrue);
        container.dispose();
      });

      test('applyLevelUp is no-op when already applied', () {
        notifier.state = notifier.state!.copyWith(levelUpApplied: true);
        notifier.applyLevelUp();
        expect(notifier.state!.levelUpApplied, isTrue);
      });
    });

    group('treasure', () {
      test('rollTreasureManually adds treasure result', () {
        notifier.state = notifier.state!.copyWith(treasureCount: 2);
        notifier.rollTreasureManually(1, 0);
        expect(notifier.state!.treasureResults.length, 1);
        expect(notifier.state!.treasureResults.first.name, 'Gold and Jewels');
      });

      test('rollTreasureManually stops at treasureCount', () {
        notifier.state = notifier.state!.copyWith(treasureCount: 1);
        notifier.rollTreasureManually(1, 0);
        notifier.rollTreasureManually(2, 1);
        expect(notifier.state!.treasureResults.length, 1);
      });

      test('setTreasureGoldChoice sets gold choice', () {
        notifier.state = notifier.state!.copyWith(
          treasureCount: 1,
          treasureResults: [
            const TreasureResultState(
              treasureIndex: 0,
              mainRoll: 1,
              subRoll: 0,
              name: 'Gold and Jewels',
              category: 'gold',
              categoryName: 'Gold and Jewels',
            ),
          ],
        );
        notifier.setTreasureGoldChoice(0, true);
        expect(notifier.state!.treasureResults[0].goldChoseXp, isTrue);
        expect(notifier.state!.treasureResults[0].isGoldChoiceMade, isTrue);
      });

      test('setTreasureGoldChoice is no-op for non-gold category', () {
        notifier.state = notifier.state!.copyWith(
          treasureCount: 1,
          treasureResults: [
            const TreasureResultState(
              treasureIndex: 0,
              mainRoll: 7,
              subRoll: 1,
              name: 'Dremlocke Weed',
              category: 'herb_potion',
              categoryName: 'Herb or Potion',
            ),
          ],
        );
        notifier.setTreasureGoldChoice(0, true);
        expect(notifier.state!.treasureResults[0].isGoldChoiceMade, isFalse);
      });

      test('setTreasureCount updates count', () {
        notifier.setTreasureCount(5);
        expect(notifier.state!.treasureCount, 5);
      });
    });

    group('companions', () {
      test('releaseCompanion adds to released set', () {
        notifier.releaseCompanion(3);
        expect(notifier.state!.releasedCompanionIds, contains(3));
      });

      test('undoReleaseCompanion removes from set', () {
        notifier.releaseCompanion(3);
        notifier.undoReleaseCompanion(3);
        expect(notifier.state!.releasedCompanionIds, isEmpty);
      });

      group('rulebook integration', () {
        AppDatabase db = AppDatabase(NativeDatabase.memory());
        ProviderContainer container = ProviderContainer();
        PostGameNotifier notifier = container.read(postGameProvider.notifier);

        setUp(() async {
          SharedPreferences.setMockInitialValues({});
          db = await createTestDatabase();
          final prefs = await SharedPreferences.getInstance();
          container = ProviderContainer(overrides: buildTestOverrides(
            database: db,
            sharedPreferences: prefs,
          ));
          notifier = container.read(postGameProvider.notifier);
        });

        tearDown(() {
          container.dispose();
          db.close();
        });

        test('Close Call removes non-basic equipment on finalize', () async {
          final rangerRepo = container.read(rangerRepositoryProvider);
          final sessionRepo = container.read(sessionRepositoryProvider);

          final rangerId = await rangerRepo.insertRanger(
            createTestRangerCompanion(name: 'Hero'),
          );

          final handWeaponId = await getEquipmentId(db, 'hand_weapon');
          final lightArmourId = await getEquipmentId(db, 'light_armour');
          final magicWeaponId = await getEquipmentId(db, 'magic_hand_weapon');

          await rangerRepo.insertRangerEquipment(createTestRangerEquipment(
            rangerId: rangerId, equipmentId: handWeaponId,
          ));
          await rangerRepo.insertRangerEquipment(createTestRangerEquipment(
            rangerId: rangerId, equipmentId: lightArmourId,
          ));
          await rangerRepo.insertRangerEquipment(createTestRangerEquipment(
            rangerId: rangerId, equipmentId: magicWeaponId,
          ));

          final sessionId = await sessionRepo.insertSession(SessionsCompanion.insert(
            rangerId: rangerId,
            scenarioName: 'Test',
            datePlayed: DateTime.now(),
          ));

          notifier.state = PostGameState(
            sessionId: sessionId,
            rangerId: rangerId,
            rangerName: 'Hero',
            survivalTargets: [
              SurvivalTargetState(id: rangerId, name: 'Hero', isRanger: true, result: SurvivalResult.closeCall),
            ],
          );

          await notifier.finalize();

          final remaining = await rangerRepo.getRangerEquipment(rangerId);
          expect(remaining.length, 2);
          expect(remaining.every((e) => e.equipmentId == handWeaponId || e.equipmentId == lightArmourId), isTrue);
        });

        test('Badly Wounded reduces next scenario health by -5', () async {
          final rangerRepo = container.read(rangerRepositoryProvider);
          final sessionRepo = container.read(sessionRepositoryProvider);

          final rangerId = await rangerRepo.insertRanger(
            createTestRangerCompanion(name: 'Hero'),
          );

          final sessionId = await sessionRepo.insertSession(SessionsCompanion.insert(
            rangerId: rangerId,
            scenarioName: 'Test',
            datePlayed: DateTime.now(),
          ));

          notifier.state = PostGameState(
            sessionId: sessionId,
            rangerId: rangerId,
            rangerName: 'Hero',
            survivalTargets: [
              SurvivalTargetState(id: rangerId, name: 'Hero', isRanger: true, result: SurvivalResult.badlyWounded),
            ],
          );

          await notifier.finalize();

          // ranger.health is 18 (from createTestRangerCompanion), minus 5 = 13
          final updatedHealth = await sessionRepo.getRangerCurrentHealth(rangerId);
          expect(updatedHealth, 13);
        });

        test('companion Badly Wounded reduces bonusHealth by -5', () async {
          final rangerRepo = container.read(rangerRepositoryProvider);
          final companionRepo = container.read(companionRepositoryProvider);
          final sessionRepo = container.read(sessionRepositoryProvider);

          final rangerId = await rangerRepo.insertRanger(
            createTestRangerCompanion(name: 'Hero'),
          );

          await companionRepo.insertCompanion(RangerCompanionsCompanion.insert(
            rangerId: rangerId,
            companionTypeId: 1,
            customName: 'Buddy',
            createdAt: DateTime.now(),
          ));

          final sessionId = await sessionRepo.insertSession(SessionsCompanion.insert(
            rangerId: rangerId,
            scenarioName: 'Test',
            datePlayed: DateTime.now(),
          ));

          notifier.state = PostGameState(
            sessionId: sessionId,
            rangerId: rangerId,
            rangerName: 'Hero',
            survivalTargets: [
              const SurvivalTargetState(id: 1, name: 'Buddy', isRanger: false, result: SurvivalResult.badlyWounded),
            ],
          );

          await notifier.finalize();

          final companion = await companionRepo.getCompanionById(1);
          expect(companion, isNotNull);
          expect(companion!.bonusHealth, -5);
        });
      });
    });

    group('SurvivalTargetState', () {
      test('copyWith preserves fields', () {
        const target = SurvivalTargetState(id: 1, name: 'Hero', isRanger: true);
        final copy = target.copyWith(survivalRoll: 10);
        expect(copy.survivalRoll, 10);
        expect(copy.name, 'Hero');
        expect(copy.isRanger, isTrue);
      });
    });

    group('TreasureResultState', () {
      test('copyWith preserves fields', () {
        const result = TreasureResultState(
          treasureIndex: 0,
          mainRoll: 1,
          subRoll: 0,
          name: 'Gold',
          category: 'gold',
          categoryName: 'Gold',
        );
        final copy = result.copyWith(goldChoseXp: true);
        expect(copy.goldChoseXp, isTrue);
        expect(copy.name, 'Gold');
      });
    });
  });
}
