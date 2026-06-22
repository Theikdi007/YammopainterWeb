import '../core/config/supabase_config.dart';
import '../core/mock/mock_db.dart';
import '../models/feedback_entry.dart';

/// Read-only access to the mobile app's `feedback` table. The portal only
/// reads feedback; users submit it from inside the app.
class FeedbackService {
  Future<List<FeedbackEntry>> fetchAll() async {
    if (SupabaseConfig.isDemoMode) {
      final list = MockDb.instance.feedback.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }
    final data = await SupabaseConfig.client
        .from('feedback')
        .select()
        .order('created_at', ascending: false);
    return data.map((e) => FeedbackEntry.fromMap(e)).toList();
  }

  Stream<List<FeedbackEntry>> stream() {
    return SupabaseConfig.client
        .from('feedback')
        .stream(primaryKey: ['id']).map((rows) {
      final list = rows.map((e) => FeedbackEntry.fromMap(e)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }
}
