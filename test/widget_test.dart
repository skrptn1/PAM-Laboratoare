import 'dart:async';

import 'package:gemstore/data/store_repository.dart';
import 'package:gemstore/models/store_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemstore/main.dart';
import 'package:gemstore/screens/all_products_screen.dart';
import 'package:gemstore/screens/product_screen.dart';
import 'package:gemstore/screens/cart_screen.dart';
import 'package:gemstore/state/store_cubit.dart';

import 'test_store.dart';

class CallbackRepository extends StoreRepository {
  final Future<StoreData> Function() callback;
  CallbackRepository(this.callback);
  @override
  Future<StoreData> load() => callback();
}

void main() {
  testWidgets('Home opens catalog, search handles empty results and reset', (
    tester,
  ) async {
    await tester.pumpWidget(
      GemStoreApp(repository: FixtureRepository(fixtureStore())),
    );
    await tester.pumpAndSettle();
    expect(find.text('GemStore'), findsOneWidget);
    await tester.tap(find.byTooltip('Discover'));
    await tester.pumpAndSettle();
    expect(find.byType(AllProductsScreen), findsOneWidget);
    expect(find.text('8 products'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('catalog-search')),
      'missing product',
    );
    await tester.pumpAndSettle();
    expect(find.text('No products match your search.'), findsOneWidget);
    await tester.tap(find.byTooltip('Reset filters'));
    await tester.pumpAndSettle();
    expect(find.text('8 products'), findsOneWidget);
    expect(find.byType(TextField).evaluate().single.widget, isA<TextField>());
    expect(
      (tester.widget<TextField>(find.byType(TextField))).controller!.text,
      '',
    );
  });
  testWidgets(
    'Detail favorites update catalog and Add To Cart creates a real entry',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        GemStoreApp(repository: FixtureRepository(fixtureStore())),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Discover'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('catalog-search')),
        'Sportwear',
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Sportwear Set'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sportwear Set'));
      await tester.pumpAndSettle();
      expect(find.byType(ProductScreen), findsOneWidget);
      await tester.tap(find.byTooltip('Remove from favorites'));
      await tester.pumpAndSettle();
      final cubit = tester
          .element(find.byType(ProductScreen))
          .read<StoreCubit>();
      expect(cubit.state.favorites.contains('p003'), isFalse);
      await tester.tap(find.text('Add To Cart'));
      await tester.pumpAndSettle();
      expect(cubit.state.cart.single.size, 'L');
      expect(cubit.state.cart.single.colorId, 'beige');
      await tester.tap(find.text('VIEW BAG'));
      await tester.pumpAndSettle();
      expect(find.byType(CartScreen), findsOneWidget);
      expect(find.text(r'$ 80.00'), findsNWidgets(2));
      await tester.tap(find.byTooltip('Remove item'));
      await tester.pumpAndSettle();
      expect(find.text('Your shopping bag is empty.'), findsOneWidget);
    },
  );
  testWidgets('Loading, error, retry and empty have visible UI', (
    tester,
  ) async {
    final pending = Completer<StoreData>();
    var attempt = 0;
    final repository = CallbackRepository(
      () => attempt++ == 0
          ? pending.future
          : Future.value(const StoreData(name: 'GemStore', products: [])),
    );
    await tester.pumpWidget(GemStoreApp(repository: repository));
    expect(find.text('Loading products...'), findsOneWidget);
    pending.completeError(StateError('test asset error'));
    await tester.pumpAndSettle();
    expect(
      find.text('We could not load the store. Please try again.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('No products found.'), findsOneWidget);
  });

  testWidgets('App renders data loaded asynchronously from the bundled JSON', (
    tester,
  ) async {
    final data = await tester.runAsync(() => StoreRepository().load());
    expect(data!.products.length, 8);
    await tester.pumpWidget(GemStoreApp(repository: FixtureRepository(data)));
    await tester.pumpAndSettle();
    expect(find.text('GemStore'), findsOneWidget);
    expect(find.text('Feature Products'), findsOneWidget);
  });
}
