import '../models/product.dart';

/// Images exported from the Figma design, bundled with the app.
String asset(String name) => 'assets/images/$name.png';

/// Stock photos for the items the Figma export doesn't include.
String img(String id, {int w = 600}) =>
    'https://images.unsplash.com/photo-$id?w=$w&auto=format&fit=crop';

final products = <Product>[
  Product(
    id: 'p2',
    name: 'Turtleneck Sweater',
    price: 39.99,
    image: asset('turtleneck_sweater'),
    category: Category.women,
  ),
  Product(
    id: 'p3',
    name: 'Long Sleeve Dress',
    price: 45,
    image: asset('long_sleeve_dress'),
    category: Category.women,
  ),
  Product(
    id: 'p1',
    name: 'Sportwear Set',
    price: 80,
    image: asset('sportwear_set'),
    cutout: true,
    category: Category.women,
  ),
  Product(
    id: 'p4',
    name: 'Sportwear Top',
    price: 80,
    image: img('1485968579580-b6d095142e6e'),
    category: Category.women,
  ),
  Product(
    id: 'p5',
    name: 'Rise Crop Hoodie',
    price: 43,
    image: asset('rise_crop_hoodie'),
    category: Category.women,
  ),
  Product(
    id: 'p6',
    name: 'Gym Crop Top',
    price: 39.99,
    image: asset('gym_crop_top'),
    category: Category.women,
  ),
  Product(
    id: 'p15',
    name: 'Sport Sweater',
    price: 47.99,
    image: 'assets/images/sport_sweater_full.jpg',
    category: Category.women,
  ),
  Product(
    id: 'p7',
    name: 'Classic Suit',
    price: 129,
    image: img('1617137968427-85924c800a22'),
    category: Category.men,
  ),
  Product(
    id: 'p8',
    name: 'Casual Jacket',
    price: 64.5,
    image: img('1552374196-1ab2a1c593e8'),
    category: Category.men,
  ),
  Product(
    id: 'p9',
    name: 'Basic White Tee',
    price: 19.99,
    image: img('1576566588028-4147f3842f27'),
    category: Category.men,
  ),
  Product(
    id: 'p10',
    name: 'Leather Watch',
    price: 99,
    image: img('1523275335684-37898b6baf30'),
    category: Category.accessories,
  ),
  Product(
    id: 'p11',
    name: 'Sunglasses',
    price: 25,
    image: img('1572635196237-14b3f281503f'),
    category: Category.accessories,
  ),
  Product(
    id: 'p12',
    name: 'Travel Backpack',
    price: 55,
    image: img('1553062407-98eeb64c6a62'),
    category: Category.accessories,
  ),
  Product(
    id: 'p13',
    name: 'Makeup Set',
    price: 34,
    image: img('1522335789203-aabd1fc54bc9'),
    category: Category.beauty,
  ),
  Product(
    id: 'p14',
    name: 'Cosmetics Kit',
    price: 28.5,
    image: img('1596462502278-27bfdc403348'),
    category: Category.beauty,
  ),
];

final recommended = <Product>[
  Product(
    id: 'r1',
    name: 'White fashion hoodie',
    price: 29,
    image: asset('white_fashion_hoodie'),
    category: Category.women,
  ),
  Product(
    id: 'r2',
    name: 'Cotton T-shirt',
    price: 30,
    image: asset('cotton_tshirt'),
    category: Category.men,
  ),
  Product(
    id: 'r3',
    name: 'Summer dress',
    price: 42,
    image: img('1502716119720-b23a93e5fe1b'),
    category: Category.women,
  ),
];

final reviews = <Review>[
  Review(
    name: 'Jennifer Rose',
    avatar: asset('avatar_jennifer'),
    stars: 5,
    time: '5m ago',
    text:
        'I love it. Awesome customer service!! Helped me out with adding an '
        'additional item to my order. Thanks again!',
  ),
  Review(
    name: 'Kelly Rihana',
    avatar: asset('avatar_kelly'),
    stars: 5,
    time: '9m ago',
    text:
        "I'm very happy with order, It was delivered on and good quality. "
        'Recommended!',
  ),
];

final mainBanner = asset('autumn_banner');
final newCollectionImage = asset('hang_out_party');
final slimBeautyImage = asset('slim_beauty');
final summerImage = asset('summer_collection');
final tshirtImage = asset('office_tshirt');
final dressImage = asset('elegant_dress');
