import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rangers_mobile/data/database/app_database.dart';
import 'package:rangers_mobile/ui/features/companions/views/recruit_companions_view.dart';
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

  testWidgets('shows recruit header with RP info', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: buildTestOverrides(database: db, sharedPreferences: prefs),
        child: const MaterialApp(
          home: RecruitCompanionsView(rangerId: 1, baseRecruitmentPoints: 100),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Recruit Companions'), findsOneWidget);
    expect(find.text('Total RP'), findsOneWidget);
    expect(find.text('Available RP'), findsOneWidget);
    expect(find.text('Companions'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });
}
