import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' show Value;
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/data/repositories/session_repository.dart';
import 'package:rangers_mobile/ui/features/session/views/session_list_view.dart';
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

  testWidgets('shows empty state when no sessions', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: const MaterialApp(home: SessionListView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No sessions yet'), findsOneWidget);
    expect(find.text('New Session'), findsOneWidget);
  });

  testWidgets('shows active and completed sessions', (tester) async {
    final repo = SessionRepository(db);
    final now = DateTime.now();

    await repo.insertSession(SessionsCompanion.insert(
      rangerId: 1,
      scenarioName: 'The Siege',
      datePlayed: now,
      missionName: const Value('Mission 1'),
      turnsPlayed: const Value(5),
      experienceEarned: const Value(100),
      outcome: const Value('victory'),
      isCompleted: const Value(true),
    ));

    await repo.insertSession(SessionsCompanion.insert(
      rangerId: 1,
      scenarioName: 'Active Quest',
      datePlayed: now,
      missionName: const Value(''),
      turnsPlayed: const Value(2),
      experienceEarned: const Value(0),
      outcome: const Value(''),
      isCompleted: const Value(false),
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: const MaterialApp(home: SessionListView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Active Quest'), findsOneWidget);
    expect(find.text('The Siege'), findsOneWidget);
    expect(find.text('ACTIVE SESSIONS'), findsOneWidget);
    expect(find.text('COMPLETED SESSIONS'), findsOneWidget);
    expect(find.text('100 XP'), findsOneWidget);
  });
}
