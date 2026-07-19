import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/data/repositories/ranger_repository.dart';
import 'package:rangers_mobile/data/repositories/session_repository.dart';
import 'package:rangers_mobile/router.dart';
import '../fixtures/ranger_data.dart';
import '../helpers/test_database.dart';
import '../helpers/test_providers.dart';

GoRouter createTestRouter({String initialLocation = '/session'}) => GoRouter(
  initialLocation: initialLocation,
  routes: appRouter.configuration.routes,
);

void main() {
  late AppDatabase db;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    db = await createTestDatabase();
  });

  Future<void> pumpApp(WidgetTester tester, GoRouter router) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('session list shows empty state', (tester) async {
    final router = createTestRouter();
    await pumpApp(tester, router);

    expect(find.text('No sessions yet'), findsOneWidget);
  });

  testWidgets('session setup shows ranger in dropdown', (tester) async {
    final repo = RangerRepository(db);
    await repo.insertRanger(createTestRangerCompanion(name: 'Boromir'));

    final router = createTestRouter(initialLocation: '/session/setup');
    await pumpApp(tester, router);

    expect(find.text('Start New Session'), findsOneWidget);

    // Open dropdown to see ranger
    await tester.tap(find.text('Ranger'));
    await tester.pumpAndSettle();

    expect(find.text('Boromir (Lv 0)'), findsOneWidget);

    // Select Boromir
    await tester.tap(find.text('Boromir (Lv 0)'));
    await tester.pumpAndSettle();
  });

  testWidgets('session setup creates session in DB', (tester) async {
    final repo = RangerRepository(db);
    await repo.insertRanger(createTestRangerCompanion(name: 'Boromir'));

    final router = createTestRouter(initialLocation: '/session/setup');
    await pumpApp(tester, router);

    // Open dropdown and select ranger
    await tester.tap(find.text('Ranger'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Boromir (Lv 0)'));
    await tester.pumpAndSettle();

    // Enter scenario name
    await tester.enterText(find.byType(TextFormField).first, 'The Siege');
    await tester.pump();

    // Start session - this navigates to active session
    await tester.tap(find.widgetWithText(FilledButton, 'Start Session'));
    await tester.pumpAndSettle();

    // Session created in DB
    final sessionRepo = SessionRepository(db);
    final sessions = await sessionRepo.getAllSessions();
    expect(sessions.length, 1);
    expect(sessions.first.scenarioName, 'The Siege');
    expect(sessions.first.isCompleted, false);

    // Should navigate to active session
    expect(find.textContaining('Turn').evaluate().isNotEmpty, isTrue);
  });

  testWidgets('active session view loads for existing session', (tester) async {
    final rangerRepo = RangerRepository(db);
    final rangerId = await rangerRepo.insertRanger(
      createTestRangerCompanion(name: 'Boromir'),
    );

    final sessionRepo = SessionRepository(db);
    final sessionId = await sessionRepo.insertSession(
      SessionsCompanion.insert(
        rangerId: rangerId,
        scenarioName: 'The Siege',
        datePlayed: DateTime.now(),
      ),
    );

    final router = createTestRouter(initialLocation: '/session/active/$sessionId');
    await pumpApp(tester, router);

    expect(
      find.byType(CircularProgressIndicator).evaluate().isNotEmpty ||
          find.textContaining('Turn').evaluate().isNotEmpty,
      isTrue,
    );
  });
}
