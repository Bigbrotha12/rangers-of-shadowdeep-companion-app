import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/ui/features/reference/views/reference_home_view.dart';
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

  testWidgets('shows reference home with categories and search', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: const MaterialApp(home: ReferenceHomeView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reference'), findsOneWidget);
    expect(find.text('Rules Categories'), findsOneWidget);
  });

  testWidgets('shows search bar', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: const MaterialApp(home: ReferenceHomeView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Search rules, abilities, items...'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsWidgets);
  });

  testWidgets('shows category cards', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: const MaterialApp(home: ReferenceHomeView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Heroic Abilities'), findsOneWidget);
    expect(find.text('Spells'), findsOneWidget);
    expect(find.text('Skills'), findsOneWidget);
    expect(find.text('Companions'), findsOneWidget);
  });
}
