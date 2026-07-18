import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/ui/features/reference/views/reference_category_view.dart';
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

  testWidgets('shows entries for heroic_abilities category', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: const MaterialApp(
          home: ReferenceCategoryView(categoryKey: 'heroic_abilities'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Heroic Abilities'), findsOneWidget);
    expect(find.text('Dash'), findsOneWidget);
    expect(find.text('Deadly Strike'), findsOneWidget);
  });

  testWidgets('shows spells category', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: const MaterialApp(
          home: ReferenceCategoryView(categoryKey: 'spells'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Spells'), findsOneWidget);
    expect(find.text('Heal'), findsOneWidget);
    expect(find.text('Magic Bolt'), findsOneWidget);
  });
}
