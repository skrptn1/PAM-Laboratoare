import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemstore/main.dart';
import 'package:gemstore/screens/product_screen.dart';
import 'package:gemstore/screens/all_products_screen.dart';
import 'package:gemstore/state/store_cubit.dart';
import 'package:gemstore/theme.dart';

import 'test_store.dart';

void main() {
  setUpAll(() async {
    final font = FontLoader('Poppins');
    for (final weight in ['Regular', 'Light', 'SemiBold']) {
      font.addFont(rootBundle.load('assets/fonts/Poppins-$weight.ttf'));
    }
    await font.load();
  });
  for (final width in [320.0, 375.0, 390.0]) {
    testWidgets('Loaded screens fit a $width pixel phone', (tester) async {
      tester.view.physicalSize = Size(width, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final store = fixtureStore();
      await tester.pumpWidget(
        GemStoreApp(repository: FixtureRepository(store)),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(ListView).first, const Offset(0, -1100));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final cubit = StoreCubit(FixtureRepository(store));
      await cubit.load();
      addTearDown(cubit.close);
      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: MaterialApp(
            theme: buildTheme(),
            home: ProductScreen(
              product: store.products.singleWhere((p) => p.id == 'p003'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -1000),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: MaterialApp(
            theme: buildTheme(),
            home: const AllProductsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
