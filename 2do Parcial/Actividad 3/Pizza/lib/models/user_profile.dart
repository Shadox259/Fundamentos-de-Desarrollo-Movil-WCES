class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'comprador' | 'vendedor'
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.createdAt,
  });

  bool get isSeller => role == 'vendedor';
  bool get isBuyer => role == 'comprador';

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
        id: m['id'] as String,
        email: m['email'] as String? ?? '',
        fullName: m['full_name'] as String? ?? '',
        role: m['role'] as String? ?? 'comprador',
        createdAt:
            DateTime.tryParse(m['created_at']?.toString() ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'role': role,
      };
}