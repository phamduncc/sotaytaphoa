import 'package:flutter_test/flutter_test.dart';
import 'package:sotaytaphoa/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SoTayTapHoaApp());
    expect(find.byType(SoTayTapHoaApp), findsOneWidget);
  });
}
