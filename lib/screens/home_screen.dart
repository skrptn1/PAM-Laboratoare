import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/store_data.dart';
import '../state/store_cubit.dart';
import '../widgets/store_status_view.dart';
import '../widgets/favorite_button.dart';
import 'cart_screen.dart';
import '../models/product.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'all_products_screen.dart';
import 'product_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocBuilder<StoreCubit, StoreState>(
    builder: (context, state) {
      if (state.status != StoreStatus.success) {
        return Scaffold(
          body: SafeArea(
            child: StoreStatusView(
              status: state.status,
              message: state.status == StoreStatus.error ? state.error : null,
              onRetry: state.status == StoreStatus.error
                  ? context.read<StoreCubit>().load
                  : null,
            ),
          ),
        );
      }
      return _HomeContent(data: state.data!);
    },
  );
}

class _HomeContent extends StatefulWidget {
  final StoreData data;
  const _HomeContent({required this.data});

  @override
  State<_HomeContent> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<_HomeContent> {
  void _openProduct(Product p) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => ProductScreen(product: p)));
  }

  void _openAll(String title, List<Product> list) {
    context.read<StoreCubit>().resetFilters();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AllProductsScreen(
          title: title,
          productIds: list.map((p) => p.id).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final products = data.products;
    final recommended = data.productsFor(data.recommendedIds);
    final category =
        context.watch<StoreCubit>().state.category ??
        data.categories.where((c) => c.selected).firstOrNull?.id ??
        Category.women;
    final featured = data
        .productsFor(data.featuredIds)
        .where((p) => p.category == category)
        .toList();

    return Scaffold(
      drawer: const _AppDrawer(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const SizedBox(height: 24),
            const _TopBar(),
            const SizedBox(height: 28),
            _Categories(
              selected: category,
              categories: data.categories,
              onSelect: (c) => context.read<StoreCubit>().filter(c),
            ),
            const SizedBox(height: 25),
            if (data.hero != null)
              GestureDetector(
                onTap: () => _openAll(
                  data.hero!.action.isEmpty ? 'Discover' : data.hero!.action,
                  products,
                ),
                child: _MainBanner(banner: data.hero!),
              ),
            const SizedBox(height: 17),
            SectionHeader(
              title: 'Feature Products',
              onShowAll: () => _openAll('Feature Products', featured),
            ),
            SizedBox(
              height: 230,
              child: featured.isEmpty
                  ? const StoreStatusView(
                      status: StoreStatus.empty,
                      message: 'No featured products in this category.',
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      itemCount: featured.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 20),
                      itemBuilder: (_, i) => _FeatureCard(
                        product: featured[i],
                        onTap: () => _openProduct(featured[i]),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            if (data.newCollection != null)
              GestureDetector(
                onTap: () => _openAll(data.newCollection!.title, products),
                child: _NewCollectionBanner(banner: data.newCollection!),
              ),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Recommended',
              onShowAll: () => _openAll('Recommended', recommended),
            ),
            SizedBox(
              height: 76,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 4,
                ),
                itemCount: recommended.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (_, i) => _RecommendedCard(
                  product: recommended[i],
                  onTap: () => _openProduct(recommended[i]),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Top Collection',
              onShowAll: () => _openAll('Top Collection', products),
            ),
            if (data.topCollections.isNotEmpty)
              GestureDetector(
                onTap: () => _openAll('Top Collection', products),
                child: _TopCollection(data: data),
              ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          IconButton(
            icon: const DesignIcon(DesignIconKind.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          Expanded(
            child: Text(
              context.read<StoreCubit>().state.data!.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            tooltip: 'Discover',
            icon: const Icon(Icons.search),
            onPressed: () {
              context.read<StoreCubit>().resetFilters();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AllProductsScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Shopping bag',
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const CartScreen())),
            icon: Badge(
              label: Text('${context.watch<StoreCubit>().state.cartCount}'),
              isLabelVisible: context.watch<StoreCubit>().state.cartCount > 0,
              child: const Icon(Icons.shopping_bag_outlined),
            ),
          ),
        ],
      ),
    );
  }
}

class _Categories extends StatelessWidget {
  final Category selected;
  final ValueChanged<Category> onSelect;
  final List<StoreCategory> categories;

  const _Categories({
    required this.selected,
    required this.onSelect,
    required this.categories,
  });

  static const _items = [
    (Category.women, Icons.female_rounded, 'Women'),
    (Category.men, Icons.male_rounded, 'Men'),
    (Category.accessories, Icons.balcony_outlined, 'Accessories'),
    (Category.beauty, Icons.brush_outlined, 'Beauty'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final item in categories)
            Builder(
              builder: (context) {
                final cat = item.id;
                final label = item.name;
                final icon = _items.firstWhere((e) => e.$1 == cat).$2;
                return GestureDetector(
                  onTap: () => onSelect(cat),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 44,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: cat == selected
                                ? AppColors.dark
                                : Colors.transparent,
                            width: 1.2,
                          ),
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: cat == selected
                                ? AppColors.dark
                                : AppColors.lightGrey,
                          ),
                          child:
                              cat == Category.accessories ||
                                  cat == Category.beauty
                              ? DesignIcon(
                                  cat == Category.accessories
                                      ? DesignIconKind.glasses
                                      : DesignIconKind.lipstick,
                                  color: AppColors.grey,
                                )
                              : Icon(
                                  icon,
                                  size: 26,
                                  color: cat == selected
                                      ? Colors.white
                                      : AppColors.grey,
                                ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          color: cat == selected
                              ? AppColors.dark
                              : AppColors.grey,
                          fontWeight: cat == selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _MainBanner extends StatelessWidget {
  final CollectionBanner banner;
  const _MainBanner({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 168,
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppImage(banner.image, alignment: Alignment.topCenter),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.transparent, Colors.transparent],
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < banner.slides; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Icon(
                          i == banner.activeSlide
                              ? Icons.radio_button_checked
                              : Icons.circle,
                          color: Colors.white,
                          size: i == banner.activeSlide ? 10 : 5,
                        ),
                      ),
                  ],
                ),
              ),
              Positioned(
                right: 8,
                top: 16,
                child: Center(
                  child: Text(
                    banner.title.replaceAll(' ', '\n'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _FeatureCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 126,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'feature-${product.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: ColoredBox(
                      color: AppColors.lightGrey,
                      child: AppImage(
                        product.id == 'p003'
                            ? 'assets/images/sportwear_preview.png'
                            : product.image,
                        fit: product.id == 'p003'
                            ? BoxFit.contain
                            : BoxFit.cover,
                        width: 126,
                        height: 172,
                        alignment: Alignment.topCenter,
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
            const SizedBox(height: 10),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              product.priceLabel,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewCollectionBanner extends StatelessWidget {
  final CollectionBanner banner;
  const _NewCollectionBanner({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 158,
      color: AppColors.lightGrey,
      child: Row(
        children: [
          const SizedBox(width: 54),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 1, height: 14, color: AppColors.grey),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        banner.label,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.grey,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  banner.title.replaceFirst(' & ', '\n& '),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    height: 1.3,
                    color: Color(0xFF7D8293),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 140,
            child: _CutoutOnCircle(
              image: banner.image,
              circleSize: 132,
              imageHeight: 158,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendedCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _RecommendedCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFFF6F6F6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 212,
          child: Row(
            children: [
              AppImage(product.image, width: 66, height: 68),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.priceLabel,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopCollection extends StatelessWidget {
  final StoreData data;
  const _TopCollection({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          _CollectionCard(
            height: 142,
            label: data.topCollections.first.label,
            title: data.topCollections.first.title.replaceFirst(' & ', '\n& '),
            titleStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              height: 1.3,
              color: Color(0xFF7D8293),
              letterSpacing: 0.5,
            ),
            image: data.topCollections.first.image,
            circle: true,
          ),
          const SizedBox(height: 14),
          if (data.topCollections.length > 1)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AppImage(
                data.topCollections[1].image,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SmallCollectionCard(
                  label: data.categoryPromos.firstOrNull?.label ?? '',
                  title: (data.categoryPromos.firstOrNull?.title ?? '')
                      .replaceAll(' ', '\n'),
                  image: data.categoryPromos.firstOrNull?.image ?? '',
                  imageWidth: 87,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _SmallCollectionCard(
                  label: data.categoryPromos.length > 1
                      ? data.categoryPromos[1].label
                      : '',
                  title: data.categoryPromos.length > 1
                      ? data.categoryPromos[1].title.replaceAll(' ', '\n')
                      : '',
                  image: data.categoryPromos.length > 1
                      ? data.categoryPromos[1].image
                      : '',
                  imageWidth: 71,
                  imageOnRight: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final double height;
  final String label;
  final String title;
  final TextStyle titleStyle;
  final String image;
  final bool circle;

  const _CollectionCard({
    required this.height,
    required this.label,
    required this.title,
    required this.titleStyle,
    required this.image,
    this.circle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 1, height: 12, color: AppColors.grey),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(title, style: titleStyle),
              ],
            ),
          ),
          SizedBox(
            width: MediaQuery.sizeOf(context).width < 350 ? 120 : 150,
            height: height,
            child: circle
                ? _CutoutOnCircle(
                    image: image,
                    circleSize: 116,
                    imageHeight: height,
                  )
                : AppImage(image, alignment: Alignment.topCenter),
          ),
        ],
      ),
    );
  }
}

/// A transparent cut-out photo standing on a light circle, bottom aligned.
class _CutoutOnCircle extends StatelessWidget {
  final String image;
  final double circleSize;
  final double imageHeight;

  const _CutoutOnCircle({
    required this.image,
    required this.circleSize,
    required this.imageHeight,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: imageHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: circleSize,
            height: circleSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEDEDEF),
            ),
          ),
          Positioned(
            bottom: 0,
            child: AppImage(image, height: imageHeight, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}

class _SmallCollectionCard extends StatelessWidget {
  final String label;
  final String title;
  final String image;
  final double imageWidth;
  final bool imageOnRight;

  const _SmallCollectionCard({
    required this.label,
    required this.title,
    required this.image,
    required this.imageWidth,
    this.imageOnRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 194,
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: imageOnRight ? null : 0,
            right: imageOnRight ? 0 : null,
            top: 0,
            bottom: 0,
            width: imageWidth,
            child: AppImage(image, alignment: Alignment.topCenter),
          ),
          Positioned(
            left: imageOnRight ? 8 : 83,
            right: imageOnRight ? 62 : 0,
            top: 0,
            bottom: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: MediaQuery.sizeOf(context).width < 350 ? 9 : 11,
                    color: AppColors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: MediaQuery.sizeOf(context).width < 350 ? 12 : 16,
                    fontWeight: FontWeight.w300,
                    height: 1.3,
                    color: Color(0xFF7D8293),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer();
  @override
  Widget build(BuildContext context) {
    void open(Widget screen) {
      Navigator.pop(context);
      context.read<StoreCubit>().resetFilters();
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    }

    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: const Text('Guest'),
              subtitle: Text(
                'Welcome to ${context.read<StoreCubit>().state.data!.name}',
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Homepage'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Discover'),
              onTap: () => open(const AllProductsScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border),
              title: const Text('Favorites'),
              onTap: () => open(
                const AllProductsScreen(
                  title: 'Favorites',
                  favoritesOnly: true,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag_outlined),
              title: const Text('Shopping bag'),
              onTap: () => open(const CartScreen()),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About GemStore'),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'GemStore',
                  applicationVersion: 'Laborator 3',
                  children: const [
                    Text('Fashion collections and your favorite finds.'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
