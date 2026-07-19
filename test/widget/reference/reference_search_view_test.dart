import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/ui/features/reference/views/reference_search_view.dart';
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

  testWidgets('shows search hint when query is empty', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: const MaterialApp(home: ReferenceSearchView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Type to search across all rules'), findsOneWidget);
  });

  testWidgets('shows results when typing a query', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: const MaterialApp(home: ReferenceSearchView()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'dash');
    await tester.pumpAndSettle();

    expect(find.text('Dash'), findsOneWidget);
  });
}
