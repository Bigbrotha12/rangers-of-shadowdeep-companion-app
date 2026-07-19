import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/ui/features/settings/views/settings_view.dart';
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

  testWidgets('shows settings with all sections', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: const MaterialApp(home: SettingsView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Data Backup'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
    expect(find.text('Export backup'), findsOneWidget);
    expect(find.text('Import backup'), findsOneWidget);
  });

  testWidgets('shows theme segment buttons', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: const MaterialApp(home: SettingsView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('System'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Dark'), findsOneWidget);
  });

  testWidgets('shows app version info', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: const MaterialApp(home: SettingsView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Version 1.0.0'), findsOneWidget);
    expect(find.text('Rangers of Shadow Deep Companion'), findsOneWidget);
  });
}
