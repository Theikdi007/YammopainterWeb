import '../core/config/supabase_config.dart';
import '../core/mock/mock_db.dart';
import '../models/community_post.dart';

/// Read + moderation operations for community posts.
class PostService {
  Future<List<CommunityPost>> fetchAll({String? status, String? query}) async {
    if (SupabaseConfig.isDemoMode) {
      var list = MockDb.instance.posts.toList();
      if (status != null && status != 'All') {
        list = list.where((e) => e.status == status).toList();
      }
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        list = list
            .where((e) =>
                e.userName.toLowerCase().contains(q) ||
                e.description.toLowerCase().contains(q))
            .toList();
      }
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }

    var builder = SupabaseConfig.client.from('posts').select();
    if (status != null && status != 'All') {
      builder = builder.eq('status', status);
    }
    if (query != null && query.trim().isNotEmpty) {
      builder = builder.ilike('description', '%${query.trim()}%');
    }
    final data = await builder.order('created_at', ascending: false);
    return data.map((e) => CommunityPost.fromMap(e)).toList();
  }

  /// Realtime stream of all posts (newest first).
  Stream<List<CommunityPost>> stream() {
    return SupabaseConfig.client
        .from('posts')
        .stream(primaryKey: ['id']).map((rows) {
      final list = rows.map((e) => CommunityPost.fromMap(e)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<void> updateStatus(CommunityPost post, String status) async {
    if (SupabaseConfig.isDemoMode) {
      final list = MockDb.instance.posts;
      final i = list.indexWhere((e) => e.id == post.id);
      if (i != -1) list[i] = post.copyWith(status: status);
      return;
    }
    await SupabaseConfig.client
        .from('posts')
        .update({'status': status}).eq('id', post.id);
  }

  Future<void> delete(CommunityPost post) async {
    if (SupabaseConfig.isDemoMode) {
      MockDb.instance.posts.removeWhere((e) => e.id == post.id);
      return;
    }
    await SupabaseConfig.client.from('posts').delete().eq('id', post.id);
  }
}
