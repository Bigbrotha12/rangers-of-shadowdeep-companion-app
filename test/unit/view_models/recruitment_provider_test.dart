import 'package:flutter_test/flutter_test.dart';
import 'package:rangers_mobile/domain/constants/companion_types.dart';
import 'package:rangers_mobile/ui/features/companions/view_models/recruitment_provider.dart';

void main() {
  group('RecruitmentState', () {
    RecruitmentState createState({
      int baseRP = 100,
      int leadership = 0,
      int playerCount = 1,
      List<CompanionEntry> companions = const [],
    }) {
      return RecruitmentState(
        rangerId: 1,
        baseRecruitmentPoints: baseRP,
        leadershipBonus: leadership,
        playerCount: playerCount,
        currentCompanions: companions,
      );
    }

    group('totalRecruitmentPoints', () {
      test('solo returns BRP + leadership', () {
        final state = createState(leadership: 5);
        expect(state.totalRecruitmentPoints, 105);
      });

      test('2 players: (BRP x 0.5) - 10 + leadership', () {
        final state = createState(playerCount: 2);
        expect(state.totalRecruitmentPoints, 40);
      });

      test('3 players: (BRP x 0.3) - 2 + leadership', () {
        final state = createState(playerCount: 3);
        expect(state.totalRecruitmentPoints, 28);
      });

      test('4 players: BRP x 0.1 + leadership', () {
        final state = createState(playerCount: 4);
        expect(state.totalRecruitmentPoints, 10);
      });

      test('unknown player count defaults to solo', () {
        final state = createState(playerCount: 0);
        expect(state.totalRecruitmentPoints, 100);
      });
    });

    group('maxCompanions', () {
      test('1 player max is 7', () {
        expect(createState().maxCompanions, 7);
      });

      test('2 players max is 3', () {
        expect(createState(playerCount: 2).maxCompanions, 3);
      });

      test('3 players max is 2', () {
        expect(createState(playerCount: 3).maxCompanions, 2);
      });

      test('4 players max is 1', () {
        expect(createState(playerCount: 4).maxCompanions, 1);
      });

      test('unknown player count defaults to 7', () {
        expect(createState(playerCount: 0).maxCompanions, 7);
      });
    });

    group('availableRecruitmentPoints', () {
      test('full RP available initially', () {
        final state = createState();
        expect(state.availableRecruitmentPoints, 100);
      });

      test('spent RP deducted from total', () {
        const entry = CompanionEntry(
          companionTypeId: 1,
          name: 'Arcanist',
          rpCost: 40,
        );
        final state = createState(companions: [entry]);
        expect(state.availableRecruitmentPoints, 60);
      });
    });

    group('canAddMoreCompanions', () {
      test('true when under max', () {
        final state = createState();
        expect(state.canAddMoreCompanions, isTrue);
      });

      test('false when at max', () {
        final entries = List.generate(
          7,
          (i) => CompanionEntry(
            companionTypeId: i + 1,
            name: 'Companion $i',
            rpCost: 10,
          ),
        );
        final state = createState(companions: entries);
        expect(state.canAddMoreCompanions, isFalse);
      });
    });

    group('canRecruit', () {
      test('true when can add and sufficient RP', () {
        final state = createState();
        const type = CompanionTypeDefinition(
          key: 'archer',
          name: 'Archer',
          description: '',
          rpCost: 30,
          move: 6,
          fight: 2,
          shoot: 2,
          armour: 10,
          will: 4,
          health: 14,
          notes: '',
          isAnimal: false,
        );
        expect(state.canRecruit(type), isTrue);
      });

      test('false when insufficient RP', () {
        final state = createState(baseRP: 20);
        const type = CompanionTypeDefinition(
          key: 'knight',
          name: 'Knight',
          description: '',
          rpCost: 50,
          move: 6,
          fight: 3,
          shoot: 1,
          armour: 12,
          will: 4,
          health: 18,
          notes: '',
          isAnimal: false,
        );
        expect(state.canRecruit(type), isFalse);
      });

      test('false when at max companions', () {
        final entries = List.generate(
          7,
          (i) => CompanionEntry(
            companionTypeId: i + 1,
            name: 'C$i',
            rpCost: 10,
          ),
        );
        final state = createState(baseRP: 200, companions: entries);
        const type = CompanionTypeDefinition(
          key: 'rogue',
          name: 'Rogue',
          description: '',
          rpCost: 10,
          move: 6,
          fight: 1,
          shoot: 1,
          armour: 10,
          will: 5,
          health: 14,
          notes: '',
          isAnimal: false,
        );
        expect(state.canRecruit(type), isFalse);
      });
    });
  });

  group('CompanionEntry', () {
    test('effectiveRpCost returns base cost for non-conjuror', () {
      const entry = CompanionEntry(
        companionTypeId: 1,
        name: 'Arcanist',
        rpCost: 40,
      );
      expect(entry.effectiveRpCost, 40);
    });

    test('effectiveRpCost adds +10 for conjuror with third spell', () {
      const entry = CompanionEntry(
        companionTypeId: 4,
        name: 'Conjuror',
        rpCost: 40,
        hasPurchasedThirdSpell: true,
      );
      expect(entry.effectiveRpCost, 50);
    });

    test('effectiveRpCost stays base for conjuror without third spell', () {
      const entry = CompanionEntry(
        companionTypeId: 4,
        name: 'Conjuror',
        rpCost: 40,
      );
      expect(entry.effectiveRpCost, 40);
    });
  });
}
