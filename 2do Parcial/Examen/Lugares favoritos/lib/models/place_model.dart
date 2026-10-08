class PlaceModel {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String category;
  final double latitude;
  final double longitude;
  final String? photoUrl;
  final DateTime createdAt;

  const PlaceModel({
    required this.id,
    required this.userId,
    required this.name,
    this.description = '',
    this.category = 'otros',
    required this.latitude,
    required this.longitude,
    this.photoUrl,
    required this.createdAt,
  });

  factory PlaceModel.fromMap(Map<String, dynamic> m) => PlaceModel(
        id: m['id'].toString(),
        userId: m['user_id'] as String,
        name: m['name'] as String? ?? '',
        description: m['description'] as String? ?? '',
        category: m['category'] as String? ?? 'otros',
        latitude: (m['latitude'] as num).toDouble(),
        longitude: (m['longitude'] as num).toDouble(),
        photoUrl: m['photo_url'] as String?,
        createdAt: DateTime.tryParse(m['created_at']?.toString() ?? '') ??
            DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'name': name,
        'description': description,
        'category': category,
        'latitude': latitude,
        'longitude': longitude,
        'photo_url': photoUrl,
      };
}