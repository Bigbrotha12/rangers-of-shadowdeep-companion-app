import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/data/repositories/companion_repository.dart';
import 'package:rangers_mobile/data/repositories/ranger_repository.dart';
import 'package:rangers_mobile/ui/features/session/views/session_active_view.dart';
import '../../fixtures/companion_data.dart' show createTestCompanionCompanion;
import '../../fixtures/ranger_data.dart' show createTestRangerCompanion;
import '../../fixtures/session_data.dart' show insertTestSession;
import '../../helpers/test_database.dart';
import '../../helpers/test_providers.dart';

void main() {
  late AppDatabase db;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    db = await createTestDatabase();
  });

  Future<({int rangerId, int companionId, int sessionId})> seedConjurorSession({
    List<String> spellKeys = const ['heal', 'magic_bolt'],
  }) async {
    final rangerRepo = RangerRepository(db);
    final rangerId = await rangerRepo.insertRanger(
      createTestRangerCompanion(name: 'Aragorn'),
    );

    final companionRepo = CompanionRepository(db);
    final companionId = await companionRepo.insertCompanion(
      createTestCompanionCompanion(
        rangerId: rangerId,
        companionTypeId: 4, // conjuror
        customName: 'Merlin',
      ),
    );

    for (final key in spellKeys) {
      await companionRepo.addCompanionSpell(companionId, rangerId, key);
    }

    final sessionId = await insertTestSession(db, rangerId: rangerId, scenarioName: 'Skirmish');

    return (rangerId: rangerId, companionId: companionId, sessionId: sessionId);
  }

  testWidgets('displays conjuror companion spells in the active session party card', (tester) async {
    final ctx = await seedConjurorSession();

    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: MaterialApp(home: SessionActiveView(sessionId: ctx.sessionId)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Merlin'), findsOneWidget);

    // Expand the companion card to reveal the spells section.
    await tester.tap(find.text('Merlin'));
    await tester.pumpAndSettle();

    expect(find.text('Spells'), findsOneWidget);
    expect(find.text('Heal'), findsOneWidget);
    expect(find.text('Magic Bolt'), findsOneWidget);
  });

  testWidgets('marks companion spell usage and persists across session reloads', (tester) async {
    final ctx = await seedConjurorSession(spellKeys: const ['heal']);

    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: MaterialApp(home: SessionActiveView(sessionId: ctx.sessionId)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Merlin'));
    await tester.pumpAndSettle();

    // Spell checkbox is inside the inner spell Card (Card inside Card).
    final spellCards = find.ancestor(
      of: find.text('Heal'),
      matching: find.byType(Card),
    );
    final checkbox = find.descendant(
      of: spellCards.at(0),
      matching: find.byType(Checkbox),
    );
    expect(checkbox, findsOneWidget);
    expect(
      tester.widget<Checkbox>(checkbox).value,
      isFalse,
      reason: 'freshly loaded companion spell should not be used',
    );

    // Bring checkbox on-screen and toggle it.
    await tester.ensureVisible(checkbox);
    await tester.pumpAndSettle();
    await tester.tap(checkbox, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(
      tester.widget<Checkbox>(checkbox).value,
      isTrue,
      reason: 'toggling should mark the spell as used in-memory',
    );

    // The change must also be persisted to the database so that reloading
    // the session restores the used-state (regression guard for the previous
    // bug where the wrong ability key was written back).
    final abilityRows = await db.select(db.rangerAbilities).get();
    final healRow = abilityRows.firstWhere(
      (r) => r.companionId == ctx.companionId && r.abilityKey == 'heal',
    );
    expect(
      healRow.isUsedThisScenario,
      isTrue,
      reason: 'toggling a companion spell should persist isUsedThisScenario',
    );
  });

  testWidgets('restores persisted companion spell usage on reload', (tester) async {
    // Seed a ranger + conjuror with a spell that is already marked used in DB.
    final ctx = await seedConjurorSession(spellKeys: const ['heal']);
    await (db.update(db.rangerAbilities)
          ..where((a) => a.companionId.equals(ctx.companionId))
          ..where((a) => a.abilityKey.equals('heal')))
        .write(const RangerAbilitiesCompanion(isUsedThisScenario: Value(true)));

    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: MaterialApp(home: SessionActiveView(sessionId: ctx.sessionId)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Merlin'));
    await tester.pumpAndSettle();

    final spellCards = find.ancestor(
      of: find.text('Heal'),
      matching: find.byType(Card),
    );
    final checkbox = find.descendant(
      of: spellCards.at(0),
      matching: find.byType(Checkbox),
    );
    await tester.ensureVisible(checkbox);
    await tester.pumpAndSettle();
    expect(
      tester.widget<Checkbox>(checkbox).value,
      isTrue,
      reason: 'previously persisted spell usage should be restored on load',
    );
  });
}