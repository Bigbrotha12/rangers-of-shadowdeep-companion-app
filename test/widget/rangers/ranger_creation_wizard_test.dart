import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/ui/features/rangers/views/ranger_creation_wizard.dart';
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

  testWidgets('shows step indicator and first step - name entry', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: const MaterialApp(home: RangerCreationWizardView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Create Ranger'), findsOneWidget);
    expect(find.text('Name Your Ranger'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Back'), findsNothing);
  });

  testWidgets('can type name and advance to step 2', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: const MaterialApp(home: RangerCreationWizardView()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Legolas');
    await tester.pump();
    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Step 2 content
    expect(find.text('Stats'), findsOneWidget);
    expect(find.text('Heroic Abilities & Spells'), findsOneWidget);
    expect(find.text('Skills'), findsOneWidget);
    expect(find.text('Recruitment Points'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
  });

  testWidgets('step indicator shows 4 steps', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: const MaterialApp(home: RangerCreationWizardView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('empty name blocks step advance', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: const MaterialApp(home: RangerCreationWizardView()),
      ),
    );
    await tester.pumpAndSettle();

    final nextButton = find.widgetWithText(FilledButton, 'Next');
    expect(nextButton, findsOneWidget);

    // Verify button is disabled when name is empty
    final button = tester.widget<FilledButton>(nextButton);
    expect(button.onPressed, isNull);

    // Enter a name and verify button becomes enabled
    await tester.enterText(find.byType(TextField).first, 'Aragorn');
    await tester.pump();

    final enabledButton = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Next'));
    expect(enabledButton.onPressed, isNotNull);
  });
}
