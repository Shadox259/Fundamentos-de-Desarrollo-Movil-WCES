class RestaurantModel {
  final String id;
  final String sellerId;
  final String name;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String imageUrl;
  final DateTime createdAt;

  const RestaurantModel({
    required this.id,
    required this.sellerId,
    required this.name,
    this.description = '',
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phone = '',
    this.imageUrl = '',
    required this.createdAt,
  });

  factory RestaurantModel.fromMap(Map<String, dynamic> m) => RestaurantModel(
        id: m['id'].toString(),
        sellerId: m['seller_id'] as String,
        name: m['name'] as String? ?? '',
        description: m['description'] as String? ?? '',
        address: m['address'] as String? ?? '',
        latitude: (m['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (m['longitude'] as num?)?.toDouble() ?? 0,
        phone: m['phone'] as String? ?? '',
        imageUrl: m['image_url'] as String? ?? '',
        createdAt:
            DateTime.tryParse(m['created_at']?.toString() ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'seller_id': sellerId,
        'name': name,
        'description': description,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'phone': phone,
        'image_url': imageUrl,
      };
}