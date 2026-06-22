/// A push notification record created and sent from the portal.
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String target; // all, user, group
  final String targetValue; // user id / group name when applicable
  final String status; // sent, failed, scheduled
  final DateTime sentAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.target,
    required this.targetValue,
    required this.status,
    required this.sentAt,
  });

  static const targets = ['all', 'user', 'group'];

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id']?.toString() ?? '',
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      target: map['target'] as String? ?? 'all',
      targetValue: map['target_value'] as String? ?? '',
      status: map['status'] as String? ?? 'sent',
      sentAt: DateTime.tryParse(map['sent_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toInsert() => {
        'title': title,
        'body': body,
        'target': target,
        'target_value': targetValue,
        'status': status,
      };
}
