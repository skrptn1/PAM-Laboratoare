import 'product.dart';

class StoreCategory {
  final Category id;
  final String name, iconUrl;
  final bool selected;
  const StoreCategory(this.id, this.name, this.iconUrl, this.selected);
  factory StoreCategory.fromJson(Map<String, dynamic> json) => StoreCategory(
    Category.values.byName(json['id'] as String),
    json['name'] as String,
    json['iconUrl'] as String,
    json['selected'] as bool? ?? false,
  );
}

class CollectionBanner {
  final String id, label, title, image, action;
  final int slides, activeSlide;
  const CollectionBanner({
    this.id = '',
    this.label = '',
    required this.title,
    required this.image,
    this.action = '',
    this.slides = 1,
    this.activeSlide = 0,
  });
  factory CollectionBanner.fromJson(
    Map<String, dynamic> json,
    String localImage,
  ) => CollectionBanner(
    id: json['id'] as String? ?? '',
    label: (json['label'] ?? json['category']) as String? ?? '',
    title: json['title'] as String,
    image: localImage,
    action: json['action'] as String? ?? '',
    slides: (json['slides'] as num?)?.toInt() ?? 1,
    activeSlide: (json['activeSlide'] as num?)?.toInt() ?? 0,
  );
}

class StoreData {
  final String name;
  final List<StoreCategory> categories;
  final List<Product> products;
  final List<String> featuredIds, recommendedIds;
  final CollectionBanner? hero, newCollection;
  final List<CollectionBanner> topCollections, categoryPromos;
  const StoreData({
    required this.name,
    required this.products,
    this.categories = const [],
    this.featuredIds = const [],
    this.recommendedIds = const [],
    this.hero,
    this.newCollection,
    this.topCollections = const [],
    this.categoryPromos = const [],
  });

  List<Product> productsFor(Iterable<String> ids) => ids
      .map((id) => products.where((p) => p.id == id).firstOrNull)
      .whereType<Product>()
      .toList();

  factory StoreData.fromJson(Map<String, dynamic> json) {
    final home = json['homePage'] as Map<String, dynamic>;
    final detail =
        (json['productPage'] as Map<String, dynamic>?)?['product']
            as Map<String, dynamic>?;
    final featured = jsonList(home['featureProducts']);
    final recommended = jsonList(home['recommended']);
    final records = <String, Product>{};
    for (final item in [
      ...featured,
      ...recommended,
      if (detail != null) ...jsonList(detail['similarProducts']),
      ?detail,
    ]) {
      final product = Product.fromJson(item);
      records[product.id] = product;
    }
    return StoreData(
      name: home['storeName'] as String,
      categories: List.unmodifiable(
        jsonList(home['categories']).map(StoreCategory.fromJson),
      ),
      products: List.unmodifiable(records.values),
      featuredIds: List.unmodifiable(featured.map((e) => e['id'] as String)),
      recommendedIds: List.unmodifiable(
        recommended.map((e) => e['id'] as String),
      ),
      hero: home['heroBanner'] == null
          ? null
          : CollectionBanner.fromJson(
              home['heroBanner'] as Map<String, dynamic>,
              'assets/images/autumn_banner.png',
            ),
      newCollection: home['newCollection'] == null
          ? null
          : CollectionBanner.fromJson(
              home['newCollection'] as Map<String, dynamic>,
              'assets/images/hang_out_party.png',
            ),
      topCollections: List.unmodifiable(
        jsonList(home['topCollections']).map(
          (e) => CollectionBanner.fromJson(
            e,
            e['id'] == 'c001'
                ? 'assets/images/slim_beauty.png'
                : e['id'] == 'c002'
                ? 'assets/images/summer_collection.png'
                : e['imageUrl'] as String,
          ),
        ),
      ),
      categoryPromos: List.unmodifiable(
        jsonList(home['categoryPromos']).map(
          (e) => CollectionBanner.fromJson(
            e,
            e['id'] == 'cp001'
                ? 'assets/images/office_tshirt.png'
                : e['id'] == 'cp002'
                ? 'assets/images/elegant_dress.png'
                : e['imageUrl'] as String,
          ),
        ),
      ),
    );
  }
}
