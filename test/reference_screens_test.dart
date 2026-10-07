import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemstore/main.dart';
import 'package:gemstore/screens/product_screen.dart';
import 'package:gemstore/theme.dart';

void main() {
  setUpAll(() async {
    final font = FontLoader('Poppins');
    for (final weight in ['Regular', 'Light', 'SemiBold']) {
      font.addFont(rootBundle.load('assets/fonts/Poppins-$weight.ttf'));
    }
    await font.load();
  });

  for (final width in [320.0, 375.0, 390.0]) {
    testWidgets('Reference screens fit a $width pixel phone', (tester) async {
      tester.view.physicalSize = Size(width, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const GemStoreApp());
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(ListView).first, const Offset(0, -1100));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(
        MaterialApp(theme: buildTheme(), home: const ProductScreen()),
      );
      await tester.pump();
      expect(find.text('Sportwear Set'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -1000),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Home opens the fixed Sportwear Set mockup', (tester) async {
    await tester.pumpWidget(const GemStoreApp());
    await tester.ensureVisible(find.text('Turtleneck Sweater'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Turtleneck Sweater'));
    await tester.pumpAndSettle();
    expect(find.byType(ProductScreen), findsOneWidget);
    expect(find.text('Add To Cart'), findsOneWidget);
    expect(find.text('Sportwear Set'), findsOneWidget);
    expect(find.text('Turtleneck Sweater'), findsNothing);
    await tester.tap(find.text('Add To Cart'));
    await tester.pump();
    expect(find.byType(SnackBar), findsNothing);
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Long Sleeve Dress'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Long Sleeve Dress'));
    await tester.pumpAndSettle();
    expect(find.text('Sportwear Set'), findsOneWidget);
    expect(find.text('Long Sleeve Dress'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
