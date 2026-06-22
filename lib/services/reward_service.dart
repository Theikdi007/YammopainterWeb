import '../core/config/supabase_config.dart';
import '../core/mock/mock_db.dart';
import '../models/reward.dart';

/// CRUD for rewards plus read access to per-user reward grants.
class RewardService {
  Future<List<Reward>> fetchAll() async {
    if (SupabaseConfig.isDemoMode) {
      final list = MockDb.instance.rewards.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }
    final data = await SupabaseConfig.client
        .from('rewards')
        .select()
        .order('created_at', ascending: false);
    return data.map((e) => Reward.fromMap(e)).toList();
  }

  /// Realtime stream of rewards (newest first).
  Stream<List<Reward>> stream() {
    return SupabaseConfig.client
        .from('rewards')
        .stream(primaryKey: ['id']).map((rows) {
      final list = rows.map((e) => Reward.fromMap(e)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  /// Realtime stream of per-user reward grants (newest first).
  Stream<List<UserReward>> streamUserRewards() {
    return SupabaseConfig.client
        .from('user_rewards')
        .stream(primaryKey: ['id']).map((rows) {
      final list = rows.map((e) => UserReward.fromMap(e)).toList();
      list.sort((a, b) => b.awardedAt.compareTo(a.awardedAt));
      return list;
    });
  }

  Future<Reward> create({
    required String name,
    required String description,
    required int points,
    required String type,
  }) async {
    if (SupabaseConfig.isDemoMode) {
      final r = Reward(
        id: MockDb.instance.nextId(),
        name: name,
        description: description,
        points: points,
        type: type,
        isActive: true,
        createdAt: DateTime.now(),
      );
      MockDb.instance.rewards.insert(0, r);
      return r;
    }
    final row = await SupabaseConfig.client
        .from('rewards')
        .insert({
          'name': name,
          'description': description,
          'points': points,
          'type': type,
          'is_active': true,
        })
        .select()
        .single();
    return Reward.fromMap(row);
  }

  Future<void> update(Reward reward) async {
    if (SupabaseConfig.isDemoMode) {
      final list = MockDb.instance.rewards;
      final i = list.indexWhere((e) => e.id == reward.id);
      if (i != -1) list[i] = reward;
      return;
    }
    await SupabaseConfig.client.from('rewards').update({
      'name': reward.name,
      'description': reward.description,
      'points': reward.points,
      'type': reward.type,
      'is_active': reward.isActive,
    }).eq('id', reward.id);
  }

  Future<void> setActive(Reward reward, bool value) =>
      update(reward.copyWith(isActive: value));

  Future<void> delete(Reward reward) async {
    if (SupabaseConfig.isDemoMode) {
      MockDb.instance.rewards.removeWhere((e) => e.id == reward.id);
      return;
    }
    await SupabaseConfig.client.from('rewards').delete().eq('id', reward.id);
  }

  Future<List<UserReward>> fetchUserRewards({String? query}) async {
    if (SupabaseConfig.isDemoMode) {
      var list = MockDb.instance.userRewards.toList();
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        list = list
            .where((e) =>
                e.userEmail.toLowerCase().contains(q) ||
                e.rewardName.toLowerCase().contains(q))
            .toList();
      }
      list.sort((a, b) => b.awardedAt.compareTo(a.awardedAt));
      return list;
    }
    var builder = SupabaseConfig.client.from('user_rewards').select();
    if (query != null && query.trim().isNotEmpty) {
      builder = builder.ilike('user_email', '%${query.trim()}%');
    }
    final data = await builder.order('awarded_at', ascending: false);
    return data.map((e) => UserReward.fromMap(e)).toList();
  }
}
