import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../state/store_cubit.dart';
import '../widgets/common.dart';
import '../widgets/store_status_view.dart';
import 'product_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Shopping bag')),
    body: BlocBuilder<StoreCubit, StoreState>(
      builder: (context, state) {
        if (state.cart.isEmpty) {
          return const StoreStatusView(
            status: StoreStatus.empty,
            message: 'Your shopping bag is empty.',
          );
        }
        final cubit = context.read<StoreCubit>();
        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: state.cart.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (_, i) {
                  final item = state.cart[i];
                  final color = item.product.colorOptions
                      .where((c) => c.id == item.colorId)
                      .firstOrNull;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductScreen(product: item.product),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AppImage(
                            item.product.image,
                            width: 70,
                            height: 100,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              [
                                if (item.size != null) 'Size ${item.size}',
                                if (color != null) color.name,
                              ].join(' / '),
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(item.product.priceLabel),
                            Row(
                              children: [
                                IconButton(
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  tooltip: 'Decrease quantity',
                                  onPressed: () =>
                                      cubit.changeQuantity(item.key, -1),
                                  icon: const Icon(Icons.remove),
                                ),
                                Text('${item.quantity}'),
                                IconButton(
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  tooltip: 'Increase quantity',
                                  onPressed: () =>
                                      cubit.changeQuantity(item.key, 1),
                                  icon: const Icon(Icons.add),
                                ),
                                const Spacer(),
                                IconButton(
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  tooltip: 'Remove item',
                                  onPressed: () =>
                                      cubit.removeFromCart(item.key),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(child: Text('Total (${state.cartCount} items)')),
                    const SizedBox(width: 12),
                    Text(
                      '\$ ${state.cartTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
