import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' show Value;
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/data/repositories/ranger_repository.dart';
import 'package:rangers_mobile/ui/features/rangers/views/rangers_list_view.dart';
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

  testWidgets('shows empty state when no rangers exist', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: const MaterialApp(home: RangersListView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No Rangers Yet'), findsOneWidget);
    expect(find.text('Create Ranger'), findsWidgets);
  });

  testWidgets('shows ranger card when rangers exist', (tester) async {
    final repo = RangerRepository(db);
    await repo.insertRanger(RangersCompanion.insert(
      name: 'Aragorn',
      move: 6,
      fight: 4,
      shoot: 2,
      armour: 10,
      will: 6,
      health: 20,
      currentHealth: 20,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      baseRecruitmentPoints: const Value(100),
    ));

    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: const MaterialApp(home: RangersListView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aragorn'), findsOneWidget);
    expect(find.textContaining('Level'), findsOneWidget);
    expect(find.textContaining('XP'), findsOneWidget);
  });
}
