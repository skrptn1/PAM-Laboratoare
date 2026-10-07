import 'package:flutter_test/flutter_test.dart';

import 'package:gemstore/main.dart';

void main() {
  testWidgets('Home screen shows store title and sections', (tester) async {
    await tester.pumpWidget(const GemStoreApp());

    expect(find.text('GemStore'), findsOneWidget);
    expect(find.text('Feature Products'), findsOneWidget);
    expect(find.text('Turtleneck Sweater'), findsOneWidget);
  });
}
