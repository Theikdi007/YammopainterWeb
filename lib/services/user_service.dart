import '../core/config/supabase_config.dart';
import '../core/mock/mock_db.dart';
import '../models/portal_user.dart';

/// CRUD operations for portal users (the `portal_users` profile table).
///
/// NOTE: creating/deleting the underlying `auth.users` record requires the
/// Supabase service-role key and should run inside an Edge Function. The client
/// here manages the profile row; wire the admin auth calls server-side.
class UserService {
  Future<List<PortalUser>> fetchAll({String? query}) async {
    if (SupabaseConfig.isDemoMode) {
      var list = MockDb.instance.users.toList();
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        list = list
            .where((e) =>
                e.email.toLowerCase().contains(q) ||
                e.fullName.toLowerCase().contains(q))
            .toList();
      }
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }

    var builder = SupabaseConfig.client.from('portal_users').select();
    if (query != null && query.trim().isNotEmpty) {
      builder = builder.or(
          'email.ilike.%${query.trim()}%,full_name.ilike.%${query.trim()}%');
    }
    final data = await builder.order('created_at', ascending: false);
    return data.map((e) => PortalUser.fromMap(e)).toList();
  }

  /// Realtime stream of all portal users (newest first).
  Stream<List<PortalUser>> stream() {
    return SupabaseConfig.client
        .from('portal_users')
        .stream(primaryKey: ['id']).map((rows) {
      final list = rows.map((e) => PortalUser.fromMap(e)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<PortalUser> create({
    required String email,
    required String fullName,
    required String role,
  }) async {
    if (SupabaseConfig.isDemoMode) {
      final user = PortalUser(
        id: MockDb.instance.nextId(),
        email: email,
        fullName: fullName,
        role: role,
        isActive: true,
        createdAt: DateTime.now(),
      );
      MockDb.instance.users.insert(0, user);
      return user;
    }
    final row = await SupabaseConfig.client
        .from('portal_users')
        .insert({
          'email': email,
          'full_name': fullName,
          'role': role,
          'is_active': true,
        })
        .select()
        .single();
    return PortalUser.fromMap(row);
  }

  Future<void> update(PortalUser user) async {
    if (SupabaseConfig.isDemoMode) {
      final list = MockDb.instance.users;
      final i = list.indexWhere((e) => e.id == user.id);
      if (i != -1) list[i] = user;
      return;
    }
    await SupabaseConfig.client
        .from('portal_users')
        .update(user.toMap())
        .eq('id', user.id);
  }

  Future<void> updateRole(PortalUser user, String role) =>
      update(user.copyWith(role: role));

  Future<void> setActive(PortalUser user, bool value) =>
      update(user.copyWith(isActive: value));

  Future<void> delete(PortalUser user) async {
    if (SupabaseConfig.isDemoMode) {
      MockDb.instance.users.removeWhere((e) => e.id == user.id);
      return;
    }
    await SupabaseConfig.client.from('portal_users').delete().eq('id', user.id);
  }
}
