import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/data/repositories/companion_repository.dart';
import 'package:rangers_mobile/data/repositories/ranger_repository.dart';
import 'package:rangers_mobile/ui/features/companions/views/companion_detail_view.dart';
import '../../fixtures/companion_data.dart' show createTestCompanionCompanion;
import '../../fixtures/ranger_data.dart' show createTestRangerCompanion;
import '../../helpers/test_database.dart';
import '../../helpers/mock_shared_preferences.dart';
import '../../helpers/test_providers.dart';

void main() {
  late AppDatabase db;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    db = await createTestDatabase();
  });

  testWidgets('shows loading state for unknown companion', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: const MaterialApp(
          home: CompanionDetailView(rangerId: 1, companionId: 999),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Companion'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('non-animal companion shows equipment slots tab', (tester) async {
    final rangerRepo = RangerRepository(db);
    final rangerId = await rangerRepo.insertRanger(
      createTestRangerCompanion(name: 'Aragorn'),
    );

    final companionRepo = CompanionRepository(db);
    final companionId = await companionRepo.insertCompanion(
      createTestCompanionCompanion(
        rangerId: rangerId,
        companionTypeId: 12, // Recruit (non-animal)
        customName: 'Pippin',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: MaterialApp(
          home: CompanionDetailView(rangerId: rangerId, companionId: companionId),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pippin'), findsAtLeast(1));

    await tester.scrollUntilVisible(
      find.text('Equipment'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Equipment'));
    await tester.pumpAndSettle();

    expect(find.text('Animals cannot carry treasure or items.'), findsNothing);
  });

  testWidgets('animal companion shows cannot carry items message', (tester) async {
    final rangerRepo = RangerRepository(db);
    final rangerId = await rangerRepo.insertRanger(
      createTestRangerCompanion(name: 'Aragorn'),
    );

    final companionRepo = CompanionRepository(db);
    final companionId = await companionRepo.insertCompanion(
      createTestCompanionCompanion(
        rangerId: rangerId,
        companionTypeId: 6, // Hound (animal)
        customName: 'Fang',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: MaterialApp(
          home: CompanionDetailView(rangerId: rangerId, companionId: companionId),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Fang'), findsAtLeast(1));

    await tester.scrollUntilVisible(
      find.text('Equipment'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Equipment'));
    await tester.pumpAndSettle();

    expect(find.text('Animals cannot carry treasure or items.'), findsOneWidget);
  });
}
