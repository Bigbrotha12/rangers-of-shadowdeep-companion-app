import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/ui/features/reference/views/reference_detail_view.dart';
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

  testWidgets('shows heroic ability detail', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: const MaterialApp(
          home: ReferenceDetailView(
            categoryKey: 'heroic_abilities',
            entryId: 'dash',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dash'), findsAtLeast(1));
    expect(find.text('Description'), findsOneWidget);
  });

  testWidgets('shows spell detail with target info', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: const MaterialApp(
          home: ReferenceDetailView(
            categoryKey: 'spells',
            entryId: 'heal',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Heal'), findsAtLeast(1));
    expect(find.text('Target'), findsOneWidget);
  });

  testWidgets('shows not found for invalid entry', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: const MaterialApp(
          home: ReferenceDetailView(
            categoryKey: 'heroic_abilities',
            entryId: 'nonexistent',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Entry not found'), findsOneWidget);
  });
}
