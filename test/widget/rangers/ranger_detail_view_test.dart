import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart' show Value;
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/data/repositories/ranger_repository.dart';
import 'package:rangers_mobile/ui/features/rangers/views/ranger_detail_view.dart';
import '../../helpers/test_database.dart';
import '../../helpers/mock_shared_preferences.dart';
import '../../helpers/test_providers.dart';

void main() {
  late AppDatabase db;
  late SharedPreferences prefs;
  late int rangerId;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    db = await createTestDatabase();

    final repo = RangerRepository(db);
    rangerId = await repo.insertRanger(RangersCompanion.insert(
      name: 'Gandalf',
      move: 6,
      fight: 3,
      shoot: 1,
      armour: 10,
      will: 8,
      health: 18,
      currentHealth: 18,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      baseRecruitmentPoints: const Value(100),
    ));
  });

  testWidgets('shows ranger header and tabs', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: MaterialApp(home: RangerDetailView(rangerId: rangerId)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Gandalf'), findsAtLeast(1));
    expect(find.text('Stats'), findsAtLeast(1));
    expect(find.text('Abilities'), findsOneWidget);
    expect(find.text('Skills'), findsOneWidget);
    expect(find.text('Equipment'), findsOneWidget);
    expect(find.text('Companions'), findsOneWidget);
    expect(find.textContaining('Level'), findsOneWidget);
  });

  testWidgets('shows stats in stats tab', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: MaterialApp(home: RangerDetailView(rangerId: rangerId)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Recruitment Points'), findsOneWidget);
    expect(find.text('100'), findsWidgets);
  });

  testWidgets('shows empty abilities state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: MaterialApp(home: RangerDetailView(rangerId: rangerId)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Abilities'));
    await tester.pumpAndSettle();

    expect(find.text('No Abilities'), findsOneWidget);
  });

  testWidgets('shows empty companions state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: MaterialApp(home: RangerDetailView(rangerId: rangerId)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Companions'));
    await tester.pumpAndSettle();

    expect(find.text('No Companions'), findsOneWidget);
    expect(find.text('Recruit Companions'), findsOneWidget);
  });
}
