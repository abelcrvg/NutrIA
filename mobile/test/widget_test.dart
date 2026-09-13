import 'package:flutter_test/flutter_test.dart';

import 'package:nutria/main.dart';

void main() {
  testWidgets('NutrIA app root can be constructed', (WidgetTester tester) async {
    await tester.pumpWidget(const NutriApp());
    expect(find.byType(NutriApp), findsOneWidget);
  });
}
