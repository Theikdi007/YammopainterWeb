/// A user managed by the portal (admins/editors of the portal itself).
class PortalUser {
  final String id;
  final String email;
  final String fullName;
  final String role; // admin, editor
  final bool isActive;
  final DateTime createdAt;

  const PortalUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  static const roles = ['admin', 'editor'];

  bool get isAdmin => role == 'admin';

  factory PortalUser.fromMap(Map<String, dynamic> map) {
    return PortalUser(
      id: map['id']?.toString() ?? '',
      email: map['email'] as String? ?? '',
      fullName: map['full_name'] as String? ?? '',
      role: map['role'] as String? ?? 'editor',
      isActive: map['is_active'] as bool? ?? true,
      createdAt:
          DateTime.tryParse(map['created_at']?.toString() ?? '') ??
              DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'full_name': fullName,
        'role': role,
        'is_active': isActive,
      };

  PortalUser copyWith({
    String? email,
    String? fullName,
    String? role,
    bool? isActive,
  }) {
    return PortalUser(
      id: id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}
