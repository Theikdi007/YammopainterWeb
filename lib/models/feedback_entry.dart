/// A single in-app feedback row from the mobile app's `feedback` table.
///
/// Named `FeedbackEntry` (not `Feedback`) to avoid clashing with Flutter's
/// material `Feedback` helper class.
class FeedbackEntry {
  final String id;
  final String userId; // auth.users id of the sender
  final String category; // bug, suggestion, praise, other
  final String? sentiment; // happy, neutral, sad (null when sent from the form)
  final String message;
  final String? platform; // ios, android, web, ...
  final String? appVersion;
  final DateTime createdAt;

  const FeedbackEntry({
    required this.id,
    required this.userId,
    required this.category,
    this.sentiment,
    required this.message,
    this.platform,
    this.appVersion,
    required this.createdAt,
  });

  static const categories = ['bug', 'suggestion', 'praise', 'other'];
  static const sentiments = ['happy', 'neutral', 'sad'];

  factory FeedbackEntry.fromMap(Map<String, dynamic> map) {
    return FeedbackEntry(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      category: map['category'] as String? ?? 'other',
      sentiment: map['sentiment'] as String?,
      message: map['message'] as String? ?? '',
      platform: map['platform'] as String?,
      appVersion: map['app_version'] as String?,
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
