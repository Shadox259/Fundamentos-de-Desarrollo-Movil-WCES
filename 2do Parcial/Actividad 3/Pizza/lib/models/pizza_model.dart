class PizzaModel {
  final String id;
  final String? restaurantId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> sizes;
  final double rating;
  final int reviewsCount;
  final String category;
  final bool isAvailable;
  final String? restaurantName;
  final String? restaurantAddress;
  final double? restaurantLatitude;
  final double? restaurantLongitude;
  final DateTime? createdAt;

  const PizzaModel({
    required this.id,
    this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.sizes = const ['Personal', 'Mediana', 'Familiar'],
    this.rating = 4.8,
    this.reviewsCount = 0,
    this.category = 'Clasicas',
    this.isAvailable = true,
    this.restaurantName,
    this.restaurantAddress,
    this.restaurantLatitude,
    this.restaurantLongitude,
    this.createdAt,
  });

  factory PizzaModel.fromMap(Map<String, dynamic> m) {
    final rest = m['restaurants'] as Map<String, dynamic>?;
    return PizzaModel(
      id: m['id'].toString(),
      restaurantId: m['restaurant_id']?.toString(),
      name: m['name'] as String? ?? '',
      description: m['description'] as String? ?? '',
      price: (m['price'] as num?)?.toDouble() ?? 0,
      imageUrl: m['image_url'] as String? ?? '',
      sizes: (m['sizes'] as List?)?.map((e) => e.toString()).toList() ??
          const ['Personal', 'Mediana', 'Familiar'],
      rating: (m['rating'] as num?)?.toDouble() ?? 4.8,
      reviewsCount: (m['reviews_count'] as num?)?.toInt() ?? 0,
      category: m['category'] as String? ?? 'Clasicas',
      isAvailable: m['is_available'] as bool? ?? true,
      restaurantName: rest?['name'] as String?,
      restaurantAddress: rest?['address'] as String?,
      restaurantLatitude: (rest?['latitude'] as num?)?.toDouble(),
      restaurantLongitude: (rest?['longitude'] as num?)?.toDouble(),
      createdAt:
          DateTime.tryParse(m['created_at']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toMap() => {
        'restaurant_id': restaurantId,
        'name': name,
        'description': description,
        'price': price,
        'image_url': imageUrl,
        'sizes': sizes,
        'category': category,
        'is_available': isAvailable,
      };

  PizzaModel copyWith({
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    bool? isAvailable,
  }) =>
      PizzaModel(
        id: id,
        restaurantId: restaurantId,
        name: name ?? this.name,
        description: description ?? this.description,
        price: price ?? this.price,
        imageUrl: imageUrl ?? this.imageUrl,
        sizes: sizes,
        rating: rating,
        reviewsCount: reviewsCount,
        category: category,
        isAvailable: isAvailable ?? this.isAvailable,
      );
}