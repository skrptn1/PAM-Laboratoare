import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/product.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});
  static const _color = 0;
  static const _size = 'L';
  static const _sizes = ['S', 'M', 'L'];
  static const _galleryCount = 3;
  Product get p => products.firstWhere((product) => product.id == 'p1');

  @override
  Widget build(BuildContext context) {
    final similar = products
        .where((item) => ['p5', 'p6', 'p15'].contains(item.id))
        .toList();

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                _buildGallery(context),
                Transform.translate(
                  offset: const Offset(0, -28),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 12),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(32, 50, 32, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitle(),
                        const Divider(height: 36, color: AppColors.divider),
                        _buildOptions(),
                        const Divider(height: 36, color: AppColors.divider),
                        _StaticSection(
                          title: 'Description',
                          child: _Description(text: p.description),
                        ),
                        const SizedBox(height: 16),
                        _StaticSection(
                          title: 'Reviews',
                          child: _Reviews(product: p),
                        ),
                        const SizedBox(height: 16),
                        _StaticSection(
                          title: 'Similar Product',
                          child: _SimilarProducts(products: similar),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _AddToCartBar(),
    );
  }

  Widget _buildGallery(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return SizedBox(
      height: 410 + top,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: AppColors.peach,
              child: p.cutout
                  ? _CutoutGalleryPage(image: p.image, topInset: top)
                  : AppImage(p.image, alignment: Alignment.topCenter),
            ),
          ),
          Positioned(
            top: top + 36,
            left: 32,
            child: CircleIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            top: top + 36,
            right: 32,
            child: CircleIconButton(
              icon: Icons.favorite_rounded,
              color: AppColors.red,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 38,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_galleryCount, (i) {
                final active = i == 0;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 10 : 6,
                  height: active ? 10 : 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active ? AppColors.dark : Colors.white,
                    border: Border.all(
                      color: AppColors.dark.withValues(alpha: 0.4),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                p.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '\$ ${p.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            StarRow(rating: p.rating, size: 22),
            const SizedBox(width: 6),
            Text(
              '(${p.ratingsCount})',
              style: const TextStyle(fontSize: 12, color: AppColors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptions() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Color',
                style: TextStyle(fontSize: 13, color: AppColors.grey),
              ),
              const SizedBox(height: 10),
              Row(
                children: List.generate(p.colors.length, (i) {
                  final selected = i == _color;
                  return GestureDetector(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected ? Colors.white : Colors.transparent,
                        boxShadow: selected
                            ? const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ]
                            : null,
                        border: Border.all(color: Colors.transparent),
                      ),
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: p.colors[i],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Size',
              style: TextStyle(fontSize: 13, color: AppColors.grey),
            ),
            const SizedBox(height: 10),
            Row(
              children: _sizes.map((s) {
                final selected = s == _size;
                return GestureDetector(
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? AppColors.dark : AppColors.lightGrey,
                    ),
                    child: Text(
                      s,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppColors.grey,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }
}

/// Gallery page for a transparent cut-out photo: model on a soft circle.
class _CutoutGalleryPage extends StatelessWidget {
  final String image;
  final double topInset;

  const _CutoutGalleryPage({required this.image, required this.topInset});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 0, bottom: 28),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 234,
            height: 234,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFCF2ED),
            ),
          ),
          Positioned(
            top: 14,
            width: 355,
            height: 532,
            child: AppImage(image, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}

class _StaticSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _StaticSection({required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    ],
  );
}

class _Description extends StatelessWidget {
  final String text;
  const _Description({required this.text});
  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 12, height: 1.7, color: AppColors.text);
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: '$text  '),
          TextSpan(
            text: 'Read more',
            style: style.copyWith(
              color: AppColors.green,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}

class _Reviews extends StatelessWidget {
  final Product product;

  const _Reviews({required this.product});

  static const _distribution = [80, 12, 5, 3, 0];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              product.rating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
            const SizedBox(width: 6),
            const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                'OUT OF 5',
                style: TextStyle(fontSize: 10, color: AppColors.grey),
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StarRow(rating: product.rating, size: 20),
                const SizedBox(height: 4),
                Text(
                  '${product.ratingsCount} ratings',
                  style: const TextStyle(fontSize: 10, color: AppColors.grey),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < 5; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                SizedBox(
                  width: 14,
                  child: Text(
                    '${5 - i}',
                    style: const TextStyle(fontSize: 12, color: AppColors.grey),
                  ),
                ),
                const Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: AppColors.green,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _distribution[i] / 100,
                      minHeight: 4,
                      backgroundColor: AppColors.lightGrey,
                      color: AppColors.green,
                    ),
                  ),
                ),
                SizedBox(
                  width: 42,
                  child: Text(
                    '${_distribution[i]}%',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontSize: 12, color: AppColors.grey),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text(
              '47 Reviews',
              style: TextStyle(fontSize: 12, color: AppColors.grey),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: null,
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.edit_outlined, size: 14),
              label: const Text(
                'WRITE A REVIEW',
                style: TextStyle(fontSize: 11),
              ),
              style: TextButton.styleFrom(foregroundColor: AppColors.grey),
            ),
          ],
        ),
        const SizedBox(height: 20),
        for (final r in reviews) _ReviewTile(review: r),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Review review;

  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipOval(child: AppImage(review.avatar, width: 36, height: 36)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    StarRow(rating: review.stars.toDouble(), size: 13),
                  ],
                ),
              ),
              Text(
                review.time,
                style: const TextStyle(fontSize: 10, color: AppColors.grey),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.text,
            style: const TextStyle(
              fontSize: 10.5,
              height: 1.6,
              color: Color(0xFF555555),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimilarProducts extends StatelessWidget {
  final List<Product> products;

  const _SimilarProducts({required this.products});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(width: 20),
        itemBuilder: (context, i) {
          final item = products[i];
          return SizedBox(
            width: 126,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ColoredBox(
                    color: AppColors.lightGrey,
                    child: AppImage(
                      item.image,
                      fit: item.cutout ? BoxFit.contain : BoxFit.cover,
                      width: 126,
                      height: 172,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.priceLabel,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AddToCartBar extends StatelessWidget {
  const _AddToCartBar();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.dark,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  'Add To Cart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
