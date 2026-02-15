import 'package:flutter_test/flutter_test.dart';

import 'package:rockcreek_app/main.dart';

void main() {
  testWidgets('App renders bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const RockCreekApp());

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Sermons'), findsOneWidget);
    expect(find.text('Events'), findsOneWidget);
    expect(find.text('Connect'), findsOneWidget);
  });
}
