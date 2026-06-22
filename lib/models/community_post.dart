/// A post submitted by a mobile-app user to the community feed.
class CommunityPost {
  final String id;
  final String userName;
  final String userEmail;
  final String imageUrl;
  final String description;
  final int likes;
  final int comments;
  final String status; // active, reported, removed
  final DateTime createdAt;

  const CommunityPost({
    required this.id,
    required this.userName,
    required this.userEmail,
    required this.imageUrl,
    required this.description,
    required this.likes,
    required this.comments,
    required this.status,
    required this.createdAt,
  });

  static const statuses = ['active', 'reported', 'removed'];

  factory CommunityPost.fromMap(Map<String, dynamic> map) {
    return CommunityPost(
      id: map['id']?.toString() ?? '',
      userName: map['user_name'] as String? ?? 'Unknown',
      userEmail: map['user_email'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? '',
      description: map['description'] as String? ?? '',
      likes: (map['likes_count'] as num?)?.toInt() ?? 0,
      comments: (map['comments_count'] as num?)?.toInt() ?? 0,
      status: map['status'] as String? ?? 'active',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  CommunityPost copyWith({String? status}) {
    return CommunityPost(
      id: id,
      userName: userName,
      userEmail: userEmail,
      imageUrl: imageUrl,
      description: description,
      likes: likes,
      comments: comments,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
