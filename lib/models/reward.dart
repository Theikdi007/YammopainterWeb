/// A reward that users can earn inside the mobile apps.
class Reward {
  final String id;
  final String name;
  final String description;
  final int points;
  final String type; // coins, badge, unlock
  final bool isActive;
  final DateTime createdAt;

  const Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.points,
    required this.type,
    required this.isActive,
    required this.createdAt,
  });

  static const types = ['coins', 'badge', 'unlock'];

  factory Reward.fromMap(Map<String, dynamic> map) {
    return Reward(
      id: map['id']?.toString() ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      points: (map['points'] as num?)?.toInt() ?? 0,
      type: map['type'] as String? ?? 'coins',
      isActive: map['is_active'] as bool? ?? true,
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toInsert() => {
        'name': name,
        'description': description,
        'points': points,
        'type': type,
        'is_active': isActive,
      };

  Reward copyWith({
    String? name,
    String? description,
    int? points,
    String? type,
    bool? isActive,
  }) {
    return Reward(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      points: points ?? this.points,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}

/// A reward granted to a specific user.
class UserReward {
  final String id;
  final String userEmail;
  final String rewardName;
  final int points;
  final String status; // granted, redeemed
  final DateTime awardedAt;

  const UserReward({
    required this.id,
    required this.userEmail,
    required this.rewardName,
    required this.points,
    required this.status,
    required this.awardedAt,
  });

  factory UserReward.fromMap(Map<String, dynamic> map) {
    return UserReward(
      id: map['id']?.toString() ?? '',
      userEmail: map['user_email'] as String? ?? '',
      rewardName: map['reward_name'] as String? ?? '',
      points: (map['points'] as num?)?.toInt() ?? 0,
      status: map['status'] as String? ?? 'granted',
      awardedAt: DateTime.tryParse(map['awarded_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
