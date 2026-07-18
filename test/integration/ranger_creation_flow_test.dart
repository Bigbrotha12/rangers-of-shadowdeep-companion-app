import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/data/repositories/ranger_repository.dart';
import 'package:rangers_mobile/router.dart';
import '../fixtures/ranger_data.dart';
import '../helpers/test_database.dart';
import '../helpers/mock_shared_preferences.dart';
import '../helpers/test_providers.dart';

GoRouter createTestRouter() => GoRouter(
  initialLocation: '/rangers',
  routes: appRouter.configuration.routes,
);

void main() {
  late AppDatabase db;
  late SharedPreferences prefs;
  late GoRouter router;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    db = await createTestDatabase();
    router = createTestRouter();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty state shows and FAB opens wizard', (tester) async {
    await pumpApp(tester);

    expect(find.text('No Rangers Yet'), findsOneWidget);
    expect(find.text('Create Ranger'), findsWidgets);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Create Ranger'), findsOneWidget);
    expect(find.text('Name Your Ranger'), findsOneWidget);
  });

  testWidgets('wizard validates name then creates ranger', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Enter name and advance to step 2
    await tester.enterText(find.byType(TextField).first, 'Aragorn');
    await tester.pump();

    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Step 2 (label: "Build")
    expect(find.text('Build'), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Step 3 (label: "Gear")
    expect(find.text('Gear'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Step 4 (label: "Review")
    expect(find.text('Review'), findsOneWidget);
    expect(find.text('Aragorn'), findsAtLeast(1));

    // Create
    await tester.tap(find.widgetWithText(FilledButton, 'Create Ranger'));
    await tester.pumpAndSettle();

    // Back on rangers list
    expect(find.text('Aragorn'), findsOneWidget);
  });

  testWidgets('ranger detail shows after tapping ranger card', (tester) async {
    final repo = RangerRepository(db);
    await repo.insertRanger(createTestRangerCompanion(name: 'Gimli'));

    await pumpApp(tester);

    expect(find.text('Gimli'), findsOneWidget);

    await tester.tap(find.text('Gimli'));
    await tester.pumpAndSettle();

    expect(find.text('Gimli'), findsAtLeast(1));
    expect(find.text('Stats'), findsAtLeast(1));
    expect(find.text('Abilities'), findsOneWidget);
    expect(find.text('Skills'), findsOneWidget);
    expect(find.text('Equipment'), findsOneWidget);
    expect(find.text('Companions'), findsOneWidget);
  });
}
