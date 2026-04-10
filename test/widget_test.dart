import 'package:flutter_test/flutter_test.dart';
import 'package:accounting_pro/main.dart';

void main() {
  testWidgets('App loads', (WidgetTester tester) async {
    await tester.pumpWidget(const AccountingApp());
    expect(find.text('Accounting Pro'), findsOneWidget);
  });
}
