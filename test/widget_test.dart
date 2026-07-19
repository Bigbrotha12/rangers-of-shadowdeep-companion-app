import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rangers_mobile/app.dart';
import 'helpers/test_database.dart';
import 'helpers/test_providers.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = await createTestDatabase();

    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: const RangersApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rangers'), findsWidgets);
  });
}
