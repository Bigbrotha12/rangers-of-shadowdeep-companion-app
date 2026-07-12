import 'package:flutter_test/flutter_test.dart';
import 'package:rangers_mobile/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RangersApp());
    expect(find.text('Rangers'), findsOneWidget);
  });
}
