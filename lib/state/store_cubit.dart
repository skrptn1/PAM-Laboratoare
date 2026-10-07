import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/store_repository.dart';
import '../models/product.dart';
import '../models/store_data.dart';

enum StoreStatus { loading, success, empty, error }

enum ProductSort { original, priceAscending, priceDescending, name, rating }

class CartItem {
  final Product product;
  final String? size, colorId;
  final int quantity;
  const CartItem(this.product, {this.size, this.colorId, this.quantity = 1});
  String get key => '${product.id}|${size ?? ''}|${colorId ?? ''}';
  double get total => product.price * quantity;
  CartItem withQuantity(int value) =>
      CartItem(product, size: size, colorId: colorId, quantity: value);
}

class StoreState {
  final StoreStatus status;
  final StoreData? data;
  final String query, error;
  final Category? category;
  final ProductSort sort;
  final Set<String> favorites;
  final List<CartItem> cart;
  const StoreState({
    this.status = StoreStatus.loading,
    this.data,
    this.query = '',
    this.error = '',
    this.category,
    this.sort = ProductSort.original,
    this.favorites = const {},
    this.cart = const [],
  });

  StoreState copyWith({
    StoreStatus? status,
    StoreData? data,
    String? query,
    String? error,
    Category? category,
    bool clearCategory = false,
    ProductSort? sort,
    Set<String>? favorites,
    List<CartItem>? cart,
  }) => StoreState(
    status: status ?? this.status,
    data: data ?? this.data,
    query: query ?? this.query,
    error: error ?? this.error,
    category: clearCategory ? null : category ?? this.category,
    sort: sort ?? this.sort,
    favorites: Set.unmodifiable(favorites ?? this.favorites),
    cart: List.unmodifiable(cart ?? this.cart),
  );

  List<Product> visibleProducts({
    Iterable<String>? ids,
    bool favoritesOnly = false,
  }) {
    final scope = ids?.toSet();
    final result = (data?.products ?? <Product>[])
        .where(
          (p) =>
              (scope == null || scope.contains(p.id)) &&
              (category == null || p.category == category) &&
              (!favoritesOnly || favorites.contains(p.id)) &&
              p.name.toLowerCase().contains(query.trim().toLowerCase()),
        )
        .toList();
    switch (sort) {
      case ProductSort.original:
        break;
      case ProductSort.priceAscending:
        result.sort((a, b) => a.price.compareTo(b.price));
      case ProductSort.priceDescending:
        result.sort((a, b) => b.price.compareTo(a.price));
      case ProductSort.name:
        result.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
      case ProductSort.rating:
        result.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return result;
  }

  int get cartCount => cart.fold(0, (count, item) => count + item.quantity);
  double get cartTotal => cart.fold(0, (total, item) => total + item.total);
}

class StoreCubit extends Cubit<StoreState> {
  final StoreRepository repository;
  bool _initialized = false, _loading = false;
  StoreCubit(this.repository) : super(const StoreState());

  Future<void> load() async {
    if (_loading) return;
    _loading = true;
    emit(state.copyWith(status: StoreStatus.loading, error: ''));
    try {
      final data = await repository.load();
      if (isClosed) return;
      final validIds = data.products.map((p) => p.id).toSet();
      final favorites = _initialized
          ? state.favorites.intersection(validIds)
          : data.products
                .where((p) => p.initiallyFavorite)
                .map((p) => p.id)
                .toSet();
      _initialized = true;
      emit(
        state.copyWith(
          data: data,
          favorites: favorites,
          status: data.products.isEmpty
              ? StoreStatus.empty
              : StoreStatus.success,
        ),
      );
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: StoreStatus.error,
            error: 'We could not load the store. Please try again.',
          ),
        );
      }
    } finally {
      _loading = false;
    }
  }

  void search(String query) => emit(state.copyWith(query: query));
  void filter(Category? category) =>
      emit(state.copyWith(category: category, clearCategory: category == null));
  void sortBy(ProductSort sort) => emit(state.copyWith(sort: sort));
  void resetFilters() => emit(
    state.copyWith(query: '', clearCategory: true, sort: ProductSort.original),
  );
  void toggleFavorite(String id) {
    if (!(state.data?.products.any((p) => p.id == id) ?? false)) return;
    final favorites = {...state.favorites};
    if (!favorites.add(id)) favorites.remove(id);
    emit(state.copyWith(favorites: favorites));
  }

  bool addToCart(Product product, {String? size, String? colorId}) {
    if (!product.canAddToCart ||
        !(state.data?.products.any((p) => p.id == product.id) ?? false)) {
      return false;
    }
    if (product.sizes.isNotEmpty &&
        (size == null ||
            !product.sizes.contains(size) ||
            !product.sizeAvailable(size))) {
      return false;
    }
    if (product.colorOptions.isNotEmpty &&
        !product.colorOptions.any((c) => c.id == colorId)) {
      return false;
    }
    final item = CartItem(product, size: size, colorId: colorId);
    final cart = [...state.cart];
    final index = cart.indexWhere((e) => e.key == item.key);
    if (index < 0) {
      cart.add(item);
    } else {
      cart[index] = cart[index].withQuantity(cart[index].quantity + 1);
    }
    emit(state.copyWith(cart: cart));
    return true;
  }

  void changeQuantity(String key, int delta) {
    final cart = [...state.cart];
    final index = cart.indexWhere((e) => e.key == key);
    if (index < 0) return;
    final quantity = cart[index].quantity + delta;
    if (quantity <= 0) {
      cart.removeAt(index);
    } else {
      cart[index] = cart[index].withQuantity(quantity);
    }
    emit(state.copyWith(cart: cart));
  }

  void removeFromCart(String key) => emit(
    state.copyWith(cart: state.cart.where((e) => e.key != key).toList()),
  );
}
