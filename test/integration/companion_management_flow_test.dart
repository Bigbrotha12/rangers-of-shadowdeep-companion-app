import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/data/repositories/ranger_repository.dart';
import 'package:rangers_mobile/data/repositories/companion_repository.dart';
import 'package:rangers_mobile/router.dart';
import '../fixtures/ranger_data.dart';
import '../helpers/test_database.dart';
import '../helpers/test_providers.dart';

GoRouter createTestRouter({String initialLocation = '/rangers/1'}) => GoRouter(
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

  testWidgets('companion types browser shows human and animal tabs', (tester) async {
    final router = createTestRouter(initialLocation: '/rangers/1/companions');
    await pumpApp(tester, router);

    expect(find.text('Companion Types'), findsOneWidget);
    expect(find.text('Human'), findsOneWidget);
    expect(find.text('Animal'), findsOneWidget);
    expect(find.text('Arcanist'), findsWidgets);
  });

  testWidgets('companion detail view shows companion info', (tester) async {
    final rangerRepo = RangerRepository(db);
    final rangerId = await rangerRepo.insertRanger(
      createTestRangerCompanion(name: 'Aragorn'),
    );

    final companionRepo = CompanionRepository(db);
    final companionId = await companionRepo.insertCompanion(
      RangerCompanionsCompanion.insert(
        rangerId: rangerId,
        companionTypeId: 1,
        customName: 'Gandalf',
        createdAt: DateTime.now(),
      ),
    );

    final router = createTestRouter(
      initialLocation: '/rangers/$rangerId/companions/$companionId',
    );
    await pumpApp(tester, router);

    expect(find.text('Gandalf'), findsAtLeast(1));
    expect(find.text('Arcanist'), findsAtLeast(1));
  });

  testWidgets('ranger detail popup menu navigates to companion types', (tester) async {
    final repo = RangerRepository(db);
    final rangerId = await repo.insertRanger(
      createTestRangerCompanion(name: 'Legolas'),
    );

    final router = createTestRouter(initialLocation: '/rangers/$rangerId');
    await pumpApp(tester, router);

    // Wait for ranger detail to load
    expect(find.text('Legolas'), findsWidgets);

    // Open the popup menu
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    // Tap "View Companions"
    await tester.tap(find.text('View Companions'));
    await tester.pumpAndSettle();

    expect(find.text('Companion Types'), findsOneWidget);
    expect(find.text('Arcanist'), findsWidgets);
  });

  testWidgets('recruit companions view opens directly', (tester) async {
    final repo = RangerRepository(db);
    final rangerId = await repo.insertRanger(
      createTestRangerCompanion(name: 'Aragorn'),
    );

    final router = createTestRouter(
      initialLocation: '/rangers/$rangerId/companions/recruit?brp=100',
    );
    await pumpApp(tester, router);

    expect(find.text('Recruit Companions'), findsOneWidget);
  });
}
