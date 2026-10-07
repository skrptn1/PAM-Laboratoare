import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gemstore/data/store_repository.dart';
import 'package:gemstore/models/product.dart';
import 'package:gemstore/state/store_cubit.dart';
import 'package:gemstore/state/product_cubit.dart';

import 'test_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'Async JSON loading merges the detail record and emits loading/success',
    () async {
      final source = Completer<String>();
      final cubit = StoreCubit(
        StoreRepository(readAsset: (_) => source.future),
      );
      addTearDown(cubit.close);
      final statuses = <StoreStatus>[];
      final subscription = cubit.stream.listen(
        (state) => statuses.add(state.status),
      );
      addTearDown(subscription.cancel);
      final success = cubit.stream.firstWhere(
        (state) => state.status == StoreStatus.success,
      );
      final loading = cubit.load();
      expect(cubit.state.status, StoreStatus.loading);
      source.complete(jsonEncode(storeJson()));
      await loading;
      await success;
      expect(statuses, [StoreStatus.loading, StoreStatus.success]);
      expect(cubit.state.data!.products.length, 8);
      final detail = cubit.state.data!.products.singleWhere(
        (p) => p.id == 'p003',
      );
      expect(detail.reviews.length, 2);
      expect(detail.sizes, ['S', 'M', 'L']);
      expect(detail.ratingBreakdown[5], 80);
      expect(cubit.state.favorites, {'p003'});
      expect(
        cubit.state.data!.products.singleWhere((p) => p.id == 'p001').reviews,
        isEmpty,
      );
    },
  );
  test('Malformed JSON enters error and retry recovers', () async {
    var source = '{broken';
    final cubit = StoreCubit(StoreRepository(readAsset: (_) async => source));
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state.status, StoreStatus.error);
    source = jsonEncode(storeJson());
    await cubit.load();
    expect(cubit.state.status, StoreStatus.success);
  });
  test('Asset read errors are handled', () async {
    final cubit = StoreCubit(
      StoreRepository(
        readAsset: (_) => Future.error(StateError('missing asset')),
      ),
    );
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state.status, StoreStatus.error);
  });
  test('An empty JSON catalog enters empty', () async {
    final cubit = StoreCubit(
      StoreRepository(
        readAsset: (_) async => jsonEncode({
          'homePage': {
            'storeName': 'GemStore',
            'featureProducts': [],
            'recommended': [],
          },
        }),
      ),
    );
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state.status, StoreStatus.empty);
  });
  test('Search, category and sorting combine and reset', () async {
    final cubit = StoreCubit(FixtureRepository(fixtureStore()));
    addTearDown(cubit.close);
    await cubit.load();
    cubit.search('  CROP  ');
    cubit.sortBy(ProductSort.priceAscending);
    expect(cubit.state.visibleProducts().map((p) => p.id), ['p007', 'p006']);
    cubit.filter(Category.men);
    expect(cubit.state.visibleProducts(), isEmpty);
    cubit.search('');
    expect(cubit.state.visibleProducts().single.id, 'p005');
    cubit.filter(Category.accessories);
    expect(cubit.state.visibleProducts(), isEmpty);
    cubit.resetFilters();
    expect(cubit.state.visibleProducts().length, 8);
    cubit.sortBy(ProductSort.priceDescending);
    expect(cubit.state.visibleProducts().first.id, 'p003');
  });
  test(
    'Favorites are shared and removed defaults stay removed on reload',
    () async {
      final cubit = StoreCubit(FixtureRepository(fixtureStore()));
      addTearDown(cubit.close);
      await cubit.load();
      cubit.toggleFavorite('p003');
      cubit.toggleFavorite('p001');
      expect(
        cubit.state.visibleProducts(favoritesOnly: true).single.id,
        'p001',
      );
      await cubit.load();
      expect(cubit.state.favorites, {'p001'});
      cubit.toggleFavorite('unknown');
      expect(cubit.state.favorites, {'p001'});
    },
  );
  test(
    'Unavailable sizes cannot be selected or added; cart aggregates variants',
    () async {
      final store = fixtureStore();
      final product = store.products.singleWhere((p) => p.id == 'p003');
      final selection = ProductCubit(product);
      final cubit = StoreCubit(FixtureRepository(store));
      addTearDown(selection.close);
      addTearDown(cubit.close);
      await cubit.load();
      expect(selection.state.size, 'L');
      selection.selectSize('S');
      expect(selection.state.size, 'L');
      expect(cubit.addToCart(product, size: 'S', colorId: 'beige'), isFalse);
      expect(cubit.addToCart(product, size: 'L', colorId: 'unknown'), isFalse);
      expect(cubit.addToCart(product, size: 'L', colorId: 'beige'), isTrue);
      cubit.addToCart(product, size: 'L', colorId: 'beige');
      cubit.addToCart(product, size: 'L', colorId: 'black');
      expect(cubit.state.cart.length, 2);
      expect(cubit.state.cartCount, 3);
      expect(cubit.state.cartTotal, 240);
      cubit.changeQuantity(cubit.state.cart.first.key, -1);
      expect(cubit.state.cartTotal, 160);
      cubit.removeFromCart(cubit.state.cart.first.key);
      cubit.changeQuantity(cubit.state.cart.single.key, -1);
      expect(cubit.state.cart, isEmpty);
    },
  );
}
