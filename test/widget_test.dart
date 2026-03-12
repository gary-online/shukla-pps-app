import 'package:flutter_test/flutter_test.dart';
import 'package:shukla_pps/main.dart';

void main() {
  testWidgets('App renders placeholder text', (WidgetTester tester) async {
    await tester.pumpWidget(const ShuklaPpsApp());
    expect(find.text('Shukla PPS — App Shell Coming Soon'), findsOneWidget);
  });
}
