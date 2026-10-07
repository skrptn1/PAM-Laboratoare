import 'package:flutter/material.dart';

import '../models/product.dart';
import '../screens/product_screen.dart';
import 'common.dart';
import 'favorite_button.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ProductScreen(product: product))),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: Hero(
                  tag: 'feature-${product.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ColoredBox(
                      color: const Color(0xFFF8F8FA),
                      child: AppImage(
                        product.image,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: FavoriteButton(productId: product.id),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12),
        ),
        Text(
          product.priceLabel,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        if (product.ratingsCount > 0) StarRow(rating: product.rating, size: 12),
      ],
    ),
  );
}
