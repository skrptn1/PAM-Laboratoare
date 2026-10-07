import 'package:flutter/material.dart';

enum Category { women, men, accessories, beauty }

class ProductColor {
  final String id;
  final String name;
  final Color value;
  const ProductColor(this.id, this.name, this.value);
  factory ProductColor.fromJson(Map<String, dynamic> json) {
    final hex = json['value'] as String;
    if (!RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(hex)) {
      throw const FormatException('Invalid product color');
    }
    return ProductColor(
      json['id'] as String,
      json['name'] as String,
      Color(int.parse('FF${hex.substring(1)}', radix: 16)),
    );
  }
}

class Product {
  final String id, name, image, remoteImage, currency, description;
  final double price, rating;
  final Category category;
  final bool cutout, initiallyFavorite, canAddToCart;
  final int ratingsCount, reviewCount;
  final List<String> gallery, sizes, similarIds;
  final List<ProductColor> colorOptions;
  final Map<String, bool> sizeAvailability;
  final String? selectedColor, selectedSize;
  final List<Review> reviews;
  final Map<int, double> ratingBreakdown;
  final String addToCartLabel;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.remoteImage,
    required this.category,
    this.currency = 'USD',
    this.description = '',
    this.rating = 0,
    this.ratingsCount = 0,
    this.reviewCount = 0,
    this.cutout = false,
    this.initiallyFavorite = false,
    this.canAddToCart = true,
    this.gallery = const [],
    this.sizes = const [],
    this.similarIds = const [],
    this.colorOptions = const [],
    this.sizeAvailability = const {},
    this.selectedColor,
    this.selectedSize,
    this.reviews = const [],
    this.ratingBreakdown = const {},
    this.addToCartLabel = 'Add To Cart',
  });

  List<Color> get colors => colorOptions.map((c) => c.value).toList();
  String get priceLabel =>
      '${currency == 'USD' ? r'$' : currency} ${price.toStringAsFixed(2)}';
  bool sizeAvailable(String size) => sizeAvailability[size] ?? true;

  factory Product.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final price = (json['price'] as num).toDouble();
    final name = json['name'] as String;
    if (id.isEmpty || name.isEmpty || price < 0 || !price.isFinite) {
      throw const FormatException('Invalid product');
    }
    final remote = (json['mainImageUrl'] ?? json['imageUrl']) as String;
    final options = jsonList(json['availableColors'])
        .map(ProductColor.fromJson)
        .toList();
    final actions = (json['actions'] as Map<String, dynamic>?) ?? {};
    return Product(
      id: id,
      name: name,
      price: price,
      remoteImage: remote,
      image: productImage(id, remote),
      currency: json['currency'] as String? ?? 'USD',
      // The supplied JSON has no category on product records. Infer only
      // the Cotton T-shirt as Men; the other reference items are Women.
      category: json['category'] == null
          ? (id == 'p005' ? Category.men : Category.women)
          : Category.values.byName(json['category'] as String),
      cutout: id == 'p003',
      description: json['description'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      ratingsCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      initiallyFavorite: actions['isFavorite'] as bool? ?? false,
      canAddToCart: actions['canAddToCart'] as bool? ?? true,
      addToCartLabel: actions['addToCartLabel'] as String? ?? 'Add To Cart',
      colorOptions: List.unmodifiable(options),
      selectedColor: json['selectedColor'] as String?,
      selectedSize: json['selectedSize'] as String?,
      sizes: List.unmodifiable(
        (json['availableSizes'] as List?)?.cast<String>() ?? [],
      ),
      sizeAvailability: Map.unmodifiable(
        (json['sizeAvailability'] as Map?)?.cast<String, bool>() ?? {},
      ),
      gallery: List.unmodifiable(
        ((json['galleryImageUrls'] as List?)?.cast<String>() ?? [remote])
            .asMap()
            .entries
            .map(
              (e) => e.key == 0
                  ? productImage(id, e.value)
                  : e.value.contains('1521572163474')
                  ? 'assets/images/cotton_tshirt.png'
                  : e.value,
            ),
      ),
      reviews: List.unmodifiable(
        jsonList(json['reviews']).map(Review.fromJson),
      ),
      similarIds: List.unmodifiable(
        jsonList(json['similarProducts']).map((e) => e['id'] as String),
      ),
      ratingBreakdown: Map.unmodifiable({
        for (final e in jsonList(json['ratingBreakdown']))
          (e['stars'] as num).toInt(): (e['percentage'] as num).toDouble(),
      }),
    );
  }
}

List<Map<String, dynamic>> jsonList(Object? value) =>
    (value as List? ?? []).map((e) => e as Map<String, dynamic>).toList();

String productImage(String id, String fallback) {
  const images = {
    'p001': 'turtleneck_sweater',
    'p002': 'long_sleeve_dress',
    'p003': 'sportwear_set',
    'p004': 'white_fashion_hoodie',
    'p005': 'cotton_tshirt',
    'p006': 'rise_crop_hoodie',
    'p007': 'gym_crop_top',
    'p008': 'sport_sweater',
  };
  final image = images[id];
  return image == null ? fallback : 'assets/images/$image.png';
}

class Review {
  final String id, name, avatar, time, text;
  final double rating;
  const Review({
    required this.id,
    required this.name,
    required this.avatar,
    required this.rating,
    required this.time,
    required this.text,
  });
  int get stars => rating.round();
  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id'] as String,
    name: json['author'] as String,
    avatar: json['id'] == 'r001'
        ? 'assets/images/avatar_jennifer.png'
        : json['id'] == 'r002'
        ? 'assets/images/avatar_kelly.png'
        : json['avatarUrl'] as String,
    rating: (json['rating'] as num).toDouble(),
    time: json['createdAtLabel'] as String,
    text: json['text'] as String,
  );
}
