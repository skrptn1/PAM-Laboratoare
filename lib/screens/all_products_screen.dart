import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../state/store_cubit.dart';
import '../widgets/catalog_controls.dart';
import '../widgets/product_card.dart';
import '../widgets/store_status_view.dart';

class AllProductsScreen extends StatelessWidget {
  final String title;
  final List<String>? productIds;
  final bool favoritesOnly;
  const AllProductsScreen({
    super.key,
    this.title = 'Discover',
    this.productIds,
    this.favoritesOnly = false,
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title), centerTitle: true),
    body: BlocBuilder<StoreCubit, StoreState>(
      builder: (context, state) {
        final cubit = context.read<StoreCubit>();
        if (state.status != StoreStatus.success) {
          return StoreStatusView(
            status: state.status,
            message: state.status == StoreStatus.error ? state.error : null,
            onRetry: state.status == StoreStatus.error ? cubit.load : null,
          );
        }
        final products = state.visibleProducts(
          ids: productIds,
          favoritesOnly: favoritesOnly,
        );
        return Column(
          children: [
            const CatalogControls(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${products.length} products',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
            Expanded(
              child: products.isEmpty
                  ? StoreStatusView(
                      status: StoreStatus.empty,
                      message: favoritesOnly && state.favorites.isEmpty
                          ? 'Your favorites list is empty.'
                          : 'No products match your search.',
                      onRetry: cubit.resetFilters,
                    )
                  : RefreshIndicator(
                      onRefresh: cubit.load,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(20),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: products.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 20,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.58,
                            ),
                        itemBuilder: (_, i) =>
                            ProductCard(product: products[i]),
                      ),
                    ),
            ),
          ],
        );
      },
    ),
  );
}
