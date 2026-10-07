import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../state/store_cubit.dart';
import '../state/product_cubit.dart';
import '../widgets/favorite_button.dart';
import 'cart_screen.dart';
import '../models/product.dart';
import '../theme.dart';
import '../widgets/common.dart';

class ProductScreen extends StatelessWidget {
  final Product product;
  const ProductScreen({super.key, required this.product});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => ProductCubit(product),
    child: _ProductContent(product: product),
  );
}

class _ProductContent extends StatefulWidget {
  final Product product;

  const _ProductContent({required this.product});

  @override
  State<_ProductContent> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<_ProductContent> {
  final _pageController = PageController();
  final _scrollController = ScrollController();
  int _page = 0;
  String? get _size => context.watch<ProductCubit>().state.size;
  int get _color => p.colorOptions.indexWhere(
    (c) => c.id == context.watch<ProductCubit>().state.colorId,
  );
  List<String> get _gallery => p.gallery.isEmpty ? [p.image] : p.gallery;

  Product get p => widget.product;

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addToCart() {
    final selection = context.read<ProductCubit>().state;
    final added = context.read<StoreCubit>().addToCart(
      p,
      size: selection.size,
      colorId: selection.colorId,
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            added
                ? '${p.name} added to your shopping bag'
                : 'Choose an available size and color.',
          ),
          action: added
              ? SnackBarAction(
                  label: 'VIEW BAG',
                  onPressed: () => Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (_) => const CartScreen())),
                )
              : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<StoreCubit>().state.data!;
    final similar = p.similarIds.isNotEmpty
        ? data.productsFor(p.similarIds)
        : data.products
              .where((item) => item.id != p.id && item.category == p.category)
              .toList();

    final statusBar = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
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
                        _ExpandableSection(
                          title: 'Description',
                          initiallyExpanded: true,
                          child: _Description(
                            text: p.description.isEmpty
                                ? 'No description provided for this product.'
                                : p.description,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _ExpandableSection(
                          title: 'Reviews',
                          initiallyExpanded: true,
                          child: _Reviews(product: p),
                        ),
                        const SizedBox(height: 16),
                        _ExpandableSection(
                          title: 'Similar Product',
                          initiallyExpanded: true,
                          child: _SimilarProducts(products: similar),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // White status-bar backdrop once the gallery has scrolled away.
          ListenableBuilder(
            listenable: _scrollController,
            builder: (_, _) {
              final show =
                  _scrollController.hasClients &&
                  _scrollController.offset > 380;
              return AnimatedOpacity(
                opacity: show ? 1 : 0,
                duration: const Duration(milliseconds: 150),
                child: Container(height: statusBar, color: Colors.white),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: _AddToCartBar(
        onTap: p.canAddToCart ? _addToCart : null,
        label: p.addToCartLabel,
      ),
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
              child: PageView.builder(
                controller: _pageController,
                itemCount: _gallery.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) {
                  final Widget image = p.cutout && i == 0
                      ? _CutoutGalleryPage(image: p.image, topInset: top)
                      : AppImage(_gallery[i], alignment: Alignment.topCenter);
                  return i == 0
                      ? Hero(tag: 'feature-${p.id}', child: image)
                      : image;
                },
              ),
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
            child: FavoriteButton(productId: p.id),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 38,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_gallery.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
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
              p.priceLabel,
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
    if (p.sizes.isEmpty && p.colors.isEmpty) {
      return const Text(
        'No size or color options provided.',
        style: TextStyle(fontSize: 12, color: AppColors.grey),
      );
    }
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
                    onTap: () => context.read<ProductCubit>().selectColor(
                      p.colorOptions[i].id,
                    ),
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
              children: p.sizes.map((s) {
                final selected = s == _size;
                return GestureDetector(
                  onTap: p.sizeAvailable(s)
                      ? () => context.read<ProductCubit>().selectSize(s)
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
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

class _ExpandableSection extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;

  const _ExpandableSection({
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  State<_ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<_ExpandableSection> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                AnimatedRotation(
                  turns: _expanded ? 0 : 0.5,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down_rounded),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _expanded
              ? Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 1, color: AppColors.divider),
                      const SizedBox(height: 20),
                      widget.child,
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _Description extends StatefulWidget {
  final String text;

  const _Description({required this.text});

  @override
  State<_Description> createState() => _DescriptionState();
}

class _DescriptionState extends State<_Description> {
  bool _more = false;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 12, height: 1.7, color: AppColors.text);
    if (widget.text.length <= 180) return Text(widget.text, style: style);
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(
            text: _more
                ? '${widget.text}  '
                : '${widget.text.substring(0, 180).trimRight()}...  ',
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: () => setState(() => _more = !_more),
              child: Text(
                _more ? 'Read less' : 'Read more',
                style: style.copyWith(
                  color: AppColors.green,
                  decoration: TextDecoration.underline,
                ),
              ),
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

  @override
  Widget build(BuildContext context) {
    if (product.ratingsCount == 0) {
      return const Text(
        'No reviews yet.',
        style: TextStyle(fontSize: 12, color: AppColors.grey),
      );
    }
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
                      value: (product.ratingBreakdown[5 - i] ?? 0) / 100,
                      minHeight: 4,
                      backgroundColor: AppColors.lightGrey,
                      color: AppColors.green,
                    ),
                  ),
                ),
                SizedBox(
                  width: 42,
                  child: Text(
                    '${(product.ratingBreakdown[5 - i] ?? 0).toStringAsFixed(0)}%',
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
            Text(
              '${product.reviewCount} Reviews',
              style: const TextStyle(fontSize: 12, color: AppColors.grey),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 20),
        for (final r in product.reviews) _ReviewTile(review: r),
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
          return GestureDetector(
            onTap: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => ProductScreen(product: item)),
            ),
            child: SizedBox(
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
            ),
          );
        },
      ),
    );
  }
}

class _AddToCartBar extends StatelessWidget {
  final VoidCallback? onTap;
  final String label;

  const _AddToCartBar({required this.onTap, required this.label});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.dark,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
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
