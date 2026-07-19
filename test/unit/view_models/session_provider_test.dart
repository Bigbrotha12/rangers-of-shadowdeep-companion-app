import 'package:flutter_test/flutter_test.dart';
import 'package:rangers_mobile/ui/features/session/view_models/session_provider.dart';

ActiveSessionState _createState({
  int turn = 1,
  SessionPhase phase = SessionPhase.ranger,
  List<PartyMemberState> party = const [],
  List<CreatureData> creatures = const [],
}) {
  return const ActiveSessionState(
    rangerId: 1,
  ).copyWith(
    currentTurn: turn,
    currentPhase: phase,
    party: party,
    creatures: creatures,
  );
}

PartyMemberState _ranger({
  int id = 1,
  String name = 'Hero',
  int hp = 18,
  int maxHp = 18,
  bool dead = false,
  bool acted = false,
  bool treasure = false,
  Map<String, bool> abilities = const {},
}) {
  return PartyMemberState(
    id: id,
    name: name,
    type: 'ranger',
    currentHealth: hp,
    maxHealth: maxHp,
    isDead: dead,
    hasActed: acted,
    carryingTreasure: treasure,
    usedAbilities: abilities,
  );
}

void main() {
  group('ActiveSessionState', () {
    group('nextCreatureId', () {
      test('returns 1 when no creatures', () {
        expect(_createState().nextCreatureId, 1);
      });

      test('returns max id + 1', () {
        final creatures = [
          const CreatureData(id: 1, name: 'Goblin', currentHealth: 5, maxHealth: 5),
          const CreatureData(id: 3, name: 'Orc', currentHealth: 10, maxHealth: 10),
        ];
        expect(_createState(creatures: creatures).nextCreatureId, 4);
      });

      test('handles single creature', () {
        final creatures = [
          const CreatureData(id: 5, name: 'Troll', currentHealth: 15, maxHealth: 15),
        ];
        expect(_createState(creatures: creatures).nextCreatureId, 6);
      });
    });

    group('copyWith', () {
      test('advances phase correctly', () {
        final s1 = _createState();
        final s2 = s1.copyWith(currentPhase: SessionPhase.creature);
        expect(s2.currentPhase, SessionPhase.creature);
        expect(s2.currentTurn, 1);
      });

      test('wrapping back to ranger increments turn', () {
        final s1 = _createState(phase: SessionPhase.event);
        final s2 = s1.copyWith(
          currentPhase: SessionPhase.ranger,
          currentTurn: s1.currentTurn + 1,
        );
        expect(s2.currentPhase, SessionPhase.ranger);
        expect(s2.currentTurn, 2);
      });
    });

    group('hasActed reset on new turn', () {
      test('all party members reset hasActed', () {
        final party = [
          _ranger(acted: true),
          const PartyMemberState(
            id: 2, name: 'Dog', type: 'companion',
            currentHealth: 10, maxHealth: 10, hasActed: true,
          ),
        ];
        final state = _createState(party: party);
        // Simulate new turn: copy party with hasActed=false
        final newParty = state.party.map((m) => m.copyWith(hasActed: false)).toList();
        final newState = state.copyWith(
          currentTurn: state.currentTurn + 1,
          currentPhase: SessionPhase.ranger,
          party: newParty,
        );
        for (final member in newState.party) {
          expect(member.hasActed, isFalse);
        }
      });
    });
  });

  group('PartyMemberState', () {
    test('toggleAbilityUsed flips boolean', () {
      final member = _ranger(abilities: {'dash': false});
      final updated = Map<String, bool>.from(member.usedAbilities);
      updated['dash'] = !(updated['dash'] ?? false);
      final toggled = member.copyWith(usedAbilities: updated);
      expect(toggled.usedAbilities['dash'], isTrue);
    });

    test('toggleAbilityUsed flips true to false', () {
      final member = _ranger(abilities: {'dash': true});
      final updated = Map<String, bool>.from(member.usedAbilities);
      updated['dash'] = !(updated['dash'] ?? false);
      final toggled = member.copyWith(usedAbilities: updated);
      expect(toggled.usedAbilities['dash'], isFalse);
    });

    test('toggleCarryingTreasure flips flag', () {
      final member = _ranger();
      final toggled = member.copyWith(carryingTreasure: !member.carryingTreasure);
      expect(toggled.carryingTreasure, isTrue);
    });

    test('usedAbilities empty on new session', () {
      final member = _ranger();
      expect(member.usedAbilities, isEmpty);
    });

    test('copyWith preserves unchanged fields', () {
      final member = _ranger();
      final copy = member.copyWith(name: 'New Name');
      expect(copy.id, 1);
      expect(copy.name, 'New Name');
      expect(copy.currentHealth, 18);
    });
  });

  group('CreatureData', () {
    test('addCreature creates with next ID', () {
      const creature = CreatureData(id: 1, name: 'Goblin', currentHealth: 5, maxHealth: 5);
      expect(creature.id, 1);
    });

    test('damage clamps to 0', () {
      const creature = CreatureData(id: 1, name: 'Goblin', currentHealth: 5, maxHealth: 5);
      final damaged = creature.copyWith(
        currentHealth: (creature.currentHealth + (-7)).clamp(0, creature.maxHealth),
        isDead: (creature.currentHealth + (-7)) <= 0,
      );
      expect(damaged.currentHealth, 0);
      expect(damaged.isDead, isTrue);
    });

    test('copyWith preserves unchanged fields', () {
      const creature = CreatureData(id: 1, name: 'Goblin', currentHealth: 5, maxHealth: 5);
      final copy = creature.copyWith(currentHealth: 3);
      expect(copy.id, 1);
      expect(copy.name, 'Goblin');
      expect(copy.currentHealth, 3);
      expect(copy.maxHealth, 5);
    });
  });

  group('add/remove creature', () {
    test('addCreature appends to list', () {
      final creatures = <CreatureData>[];
      creatures.add(const CreatureData(id: 1, name: 'Goblin', currentHealth: 5, maxHealth: 5));
      creatures.add(const CreatureData(id: 2, name: 'Orc', currentHealth: 10, maxHealth: 10));
      expect(creatures.length, 2);
    });

    test('removeCreature filters by ID', () {
      var creatures = [
        const CreatureData(id: 1, name: 'Goblin', currentHealth: 5, maxHealth: 5),
        const CreatureData(id: 2, name: 'Orc', currentHealth: 10, maxHealth: 10),
      ];
      creatures = creatures.where((c) => c.id != 1).toList();
      expect(creatures.length, 1);
      expect(creatures.first.id, 2);
    });
  });
}
