import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/product.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'product_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const Category _category = Category.women;

  void _openProduct(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => const ProductScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final featured = products
        .where((p) => ['p2', 'p3', 'p1'].contains(p.id))
        .toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const SizedBox(height: 24),
            const _TopBar(),
            const SizedBox(height: 28),
            _Categories(selected: _category),
            const SizedBox(height: 25),
            const _MainBanner(),
            const SizedBox(height: 17),
            SectionHeader(title: 'Feature Products'),
            SizedBox(
              height: 230,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                itemCount: featured.length,
                separatorBuilder: (_, _) => const SizedBox(width: 20),
                itemBuilder: (_, i) => _FeatureCard(
                  product: featured[i],
                  onTap: () => _openProduct(context),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const _NewCollectionBanner(),
            const SizedBox(height: 24),
            SectionHeader(title: 'Recommended'),
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
                  onTap: () => _openProduct(context),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SectionHeader(title: 'Top Collection'),
            const _TopCollection(),
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
          const Padding(
            padding: EdgeInsets.all(12),
            child: DesignIcon(DesignIconKind.menu),
          ),
          const Expanded(
            child: Text(
              'GemStore',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Badge(
              smallSize: 7,
              backgroundColor: AppColors.red,
              child: Icon(Icons.notifications_none_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _Categories extends StatelessWidget {
  final Category selected;

  const _Categories({required this.selected});

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
          for (final (cat, icon, label) in _items)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Column(
                children: [
                  Container(
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
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cat == selected
                            ? AppColors.dark
                            : AppColors.lightGrey,
                      ),
                      child:
                          cat == Category.accessories || cat == Category.beauty
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
                      color: cat == selected ? AppColors.dark : AppColors.grey,
                      fontWeight: cat == selected
                          ? FontWeight.w600
                          : FontWeight.w400,
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

class _MainBanner extends StatelessWidget {
  const _MainBanner();

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
              AppImage(mainBanner, alignment: Alignment.topCenter),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.transparent, Colors.transparent],
                  ),
                ),
              ),
              const Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.radio_button_checked,
                      color: Colors.white,
                      size: 10,
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.circle, color: Colors.white, size: 5),
                    SizedBox(width: 10),
                    Icon(Icons.circle, color: Colors.white, size: 5),
                  ],
                ),
              ),
              const Positioned(
                right: 8,
                top: 16,
                child: Center(
                  child: Text(
                    'Autumn\nCollection\n2021',
                    style: TextStyle(
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
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ColoredBox(
                color: AppColors.lightGrey,
                child: AppImage(
                  product.image,
                  fit: product.cutout ? BoxFit.contain : BoxFit.cover,
                  width: 126,
                  height: 172,
                  alignment: Alignment.topCenter,
                ),
              ),
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
  const _NewCollectionBanner();

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
                    const Flexible(
                      child: Text(
                        'NEW COLLECTION',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.grey,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'HANG OUT\n& PARTY',
                  style: TextStyle(
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
              image: newCollectionImage,
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
      child: GestureDetector(
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
  const _TopCollection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          _CollectionCard(
            height: 142,
            label: 'Sale up to 40%',
            title: 'FOR SLIM\n& BEAUTY',
            titleStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              height: 1.3,
              color: Color(0xFF7D8293),
              letterSpacing: 0.5,
            ),
            image: slimBeautyImage,
            circle: true,
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AppImage(
              summerImage,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SmallCollectionCard(
                  label: 'T-Shirts',
                  title: 'The\nOffice\nLife',
                  image: tshirtImage,
                  imageWidth: 87,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _SmallCollectionCard(
                  label: 'Dresses',
                  title: 'Elegant\nDesign',
                  image: dressImage,
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
