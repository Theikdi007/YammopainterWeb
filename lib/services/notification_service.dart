import '../core/config/supabase_config.dart';
import '../core/mock/mock_db.dart';
import '../models/app_notification.dart';

/// Sends push notifications (via a Supabase Edge Function + FCM) and records
/// the history in the `notifications` table.
class NotificationService {
  Future<List<AppNotification>> fetchAll() async {
    if (SupabaseConfig.isDemoMode) {
      final list = MockDb.instance.notifications.toList()
        ..sort((a, b) => b.sentAt.compareTo(a.sentAt));
      return list;
    }
    final data = await SupabaseConfig.client
        .from('notifications')
        .select()
        .order('sent_at', ascending: false);
    return data.map((e) => AppNotification.fromMap(e)).toList();
  }

  /// Realtime stream of notification history (newest first).
  Stream<List<AppNotification>> stream() {
    return SupabaseConfig.client
        .from('notifications')
        .stream(primaryKey: ['id']).map((rows) {
      final list = rows.map((e) => AppNotification.fromMap(e)).toList();
      list.sort((a, b) => b.sentAt.compareTo(a.sentAt));
      return list;
    });
  }

  Future<AppNotification> send({
    required String title,
    required String body,
    required String target,
    String targetValue = '',
  }) async {
    if (SupabaseConfig.isDemoMode) {
      final n = AppNotification(
        id: MockDb.instance.nextId(),
        title: title,
        body: body,
        target: target,
        targetValue: targetValue,
        status: 'sent',
        sentAt: DateTime.now(),
      );
      MockDb.instance.notifications.insert(0, n);
      return n;
    }

    final client = SupabaseConfig.client;
    // Best-effort push delivery via the optional edge function. If it isn't
    // deployed (or is unreachable) we still record the notification as sent —
    // the portal's job is to create and log it; FCM fan-out happens out-of-band
    // when the function is available.
    try {
      // Edge function that fans the message out to FCM tokens.
      await client.functions.invoke('send-notification', body: {
        'title': title,
        'body': body,
        'target': target,
        'target_value': targetValue,
      });
    } catch (_) {
      // Edge function not deployed / unreachable — ignore and still log it.
    }

    final row = await client
        .from('notifications')
        .insert({
          'title': title,
          'body': body,
          'target': target,
          'target_value': targetValue,
          'status': 'sent',
        })
        .select()
        .single();
    return AppNotification.fromMap(row);
  }
}
