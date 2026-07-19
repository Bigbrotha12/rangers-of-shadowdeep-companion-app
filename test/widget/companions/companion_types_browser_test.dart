import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/ui/features/companions/views/companion_types_browser.dart';
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

  testWidgets('shows human and animal tabs', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: const MaterialApp(home: CompanionTypesBrowser(rangerId: 1)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Companion Types'), findsOneWidget);
    expect(find.text('Human'), findsOneWidget);
    expect(find.text('Animal'), findsOneWidget);
  });

  testWidgets('shows companion cards with stats', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: const MaterialApp(home: CompanionTypesBrowser(rangerId: 1)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('RP:'), findsWidgets);
  });
}
