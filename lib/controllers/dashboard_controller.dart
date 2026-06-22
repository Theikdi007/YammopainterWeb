import 'dart:async';

import 'package:get/get.dart';

import '../core/config/supabase_config.dart';
import '../core/utils/ui_helpers.dart';
import '../models/app_notification.dart';
import '../models/community_post.dart';
import '../services/notification_service.dart';
import '../services/post_service.dart';
import '../services/reward_service.dart';
import '../services/svg_service.dart';
import '../services/user_service.dart';

class DashboardController extends GetxController {
  final SvgService _svg = SvgService();
  final UserService _user = UserService();
  final PostService _post = PostService();
  final RewardService _reward = RewardService();
  final NotificationService _ntf = NotificationService();

  final RxBool isLoading = true.obs;
  final RxInt svgCount = 0.obs;
  final RxInt userCount = 0.obs;
  final RxInt postCount = 0.obs;
  final RxInt activeRewards = 0.obs;
  final RxMap<String, int> svgByCategory = <String, int>{}.obs;
  final RxList<AppNotification> recentNotifications = <AppNotification>[].obs;
  final RxList<CommunityPost> recentPosts = <CommunityPost>[].obs;

  final List<StreamSubscription<dynamic>> _subs = [];

  @override
  void onInit() {
    if (SupabaseConfig.isReady) {
      _bindStreams();
    } else {
      load();
    }
    super.onInit();
  }

  @override
  void onClose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.onClose();
  }

  /// Live overview — recomputes aggregates whenever any table changes.
  void _bindStreams() {
    _subs.add(_svg.stream().listen((svgs) {
      svgCount.value = svgs.length;
      final byCategory = <String, int>{};
      for (final s in svgs) {
        byCategory[s.category] = (byCategory[s.category] ?? 0) + 1;
      }
      svgByCategory.assignAll(byCategory);
    }));
    _subs.add(_user.stream().listen((u) => userCount.value = u.length));
    _subs.add(_post.stream().listen((p) {
      postCount.value = p.length;
      recentPosts.assignAll(p.take(5));
    }));
    _subs.add(_reward
        .stream()
        .listen((r) => activeRewards.value = r.where((e) => e.isActive).length));
    _subs.add(
        _ntf.stream().listen((n) => recentNotifications.assignAll(n.take(5))));
    isLoading.value = false;
  }

  /// One-shot load (demo mode / manual refresh button).
  ///
  /// Pass [silent] to refresh data in the background without showing the
  /// full-screen loading spinner (used when re-opening the dashboard tab).
  Future<void> load({bool silent = false}) async {
    if (!silent) isLoading.value = true;
    try {
      final svgs = await _svg.fetchAll();
      final users = await _user.fetchAll();
      final posts = await _post.fetchAll();
      final rewards = await _reward.fetchAll();
      final notifications = await _ntf.fetchAll();

      svgCount.value = svgs.length;
      userCount.value = users.length;
      postCount.value = posts.length;
      activeRewards.value = rewards.where((r) => r.isActive).length;

      final byCategory = <String, int>{};
      for (final s in svgs) {
        byCategory[s.category] = (byCategory[s.category] ?? 0) + 1;
      }
      svgByCategory.assignAll(byCategory);
      recentNotifications.assignAll(notifications.take(5));
      recentPosts.assignAll(posts.take(5));
    } catch (e) {
      showError(friendlyError(e));
    } finally {
      if (!silent) isLoading.value = false;
    }
  }
}
