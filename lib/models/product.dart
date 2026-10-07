import 'package:flutter/material.dart';

enum Category { women, men, accessories, beauty }

class Product {
  final String id;
  final String name;
  final double price;
  final String image;
  final Category category;
  final double rating;
  final int ratingsCount;
  final String description;
  final List<Color> colors;

  /// True when [image] has a transparent background (a cut-out model shot).
  final bool cutout;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    this.cutout = false,
    this.rating = 4.9,
    this.ratingsCount = 83,
    this.description =
        'Sportwear is no longer under culture, it is no longer indie or cobbled '
        'together as it once was. Sport is fashion today. The top is oversized '
        'in fit and style, may need to size down.',
    this.colors = const [
      Color(0xFFE7C4A8),
      Color(0xFF1D1F22),
      Color(0xFFEB6E6E),
    ],
  });

  String get priceLabel => '\$ ${price.toStringAsFixed(2)}';
}

class Review {
  final String name;
  final String avatar;
  final int stars;
  final String time;
  final String text;

  const Review({
    required this.name,
    required this.avatar,
    required this.stars,
    required this.time,
    required this.text,
  });
}
