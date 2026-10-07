import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:discount_calculator/main.dart';

void main() {
  testWidgets('Calculează reducerea și prețul final', (tester) async {
    await tester.pumpWidget(const DiscountApp());

    await tester.enterText(find.byType(TextFormField).at(0), '200');
    await tester.enterText(find.byType(TextFormField).at(1), '15');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Valoarea reducerii: 30.00 MDL'), findsOneWidget);
    expect(find.text('Preț final: 170.00 MDL'), findsOneWidget);
  });
}
