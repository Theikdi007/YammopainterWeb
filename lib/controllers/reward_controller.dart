import 'dart:async';

import 'package:get/get.dart';

import '../core/config/supabase_config.dart';
import '../core/utils/ui_helpers.dart';
import '../models/reward.dart';
import '../services/reward_service.dart';

class RewardController extends GetxController {
  final RewardService _service = RewardService();

  final RxList<Reward> items = <Reward>[].obs;
  final RxList<UserReward> _allUserRewards = <UserReward>[].obs;
  final RxList<UserReward> userRewards = <UserReward>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingUserRewards = false.obs;
  final RxString userRewardSearch = ''.obs;

  StreamSubscription<List<Reward>>? _sub;
  StreamSubscription<List<UserReward>>? _urSub;

  @override
  void onInit() {
    if (SupabaseConfig.isReady) {
      isLoading.value = true;
      isLoadingUserRewards.value = true;
      _sub = _service.stream().listen(
        (data) {
          items.assignAll(data);
          isLoading.value = false;
        },
        onError: (Object e) {
          showError(friendlyError(e));
          isLoading.value = false;
        },
      );
      _urSub = _service.streamUserRewards().listen(
        (data) {
          _allUserRewards.assignAll(data);
          _applyUserRewardFilter();
          isLoadingUserRewards.value = false;
        },
        onError: (Object e) {
          showError(friendlyError(e));
          isLoadingUserRewards.value = false;
        },
      );
    } else {
      load();
      loadUserRewards();
    }
    super.onInit();
  }

  @override
  void onClose() {
    _sub?.cancel();
    _urSub?.cancel();
    super.onClose();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      items.assignAll(await _service.fetchAll());
    } catch (e) {
      showError(friendlyError(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserRewards() async {
    isLoadingUserRewards.value = true;
    try {
      userRewards.assignAll(
          await _service.fetchUserRewards(query: userRewardSearch.value));
    } catch (e) {
      showError(friendlyError(e));
    } finally {
      isLoadingUserRewards.value = false;
    }
  }

  void _applyUserRewardFilter() {
    final q = userRewardSearch.value.trim().toLowerCase();
    userRewards.assignAll(q.isEmpty
        ? _allUserRewards
        : _allUserRewards.where((e) =>
            e.userEmail.toLowerCase().contains(q) ||
            e.rewardName.toLowerCase().contains(q)));
  }

  /// Refresh deterministically after a mutation (works even without realtime).
  Future<void> _refresh() async {
    await load();
  }

  void setUserRewardSearch(String value) {
    userRewardSearch.value = value;
    SupabaseConfig.isReady ? _applyUserRewardFilter() : loadUserRewards();
  }

  Future<bool> create({
    required String name,
    required String description,
    required int points,
    required String type,
  }) async {
    try {
      await _service.create(
        name: name,
        description: description,
        points: points,
        type: type,
      );
      await _refresh();
      return true;
    } catch (e) {
      showError(friendlyError(e));
      return false;
    }
  }

  Future<bool> save(Reward reward) async {
    try {
      await _service.update(reward);
      await _refresh();
      return true;
    } catch (e) {
      showError(friendlyError(e));
      return false;
    }
  }

  Future<void> toggleActive(Reward reward, bool value) async {
    try {
      await _service.setActive(reward, value);
      await _refresh();
    } catch (e) {
      showError(friendlyError(e));
    }
  }

  Future<void> delete(Reward reward) async {
    try {
      await _service.delete(reward);
      await _refresh();
      await showSuccessDialog('Reward deleted.');
    } catch (e) {
      showError(friendlyError(e));
    }
  }
}
