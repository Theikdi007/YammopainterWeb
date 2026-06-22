import 'dart:async';

import 'package:get/get.dart';

import '../core/config/supabase_config.dart';
import '../core/utils/ui_helpers.dart';
import '../models/community_post.dart';
import '../services/post_service.dart';

class PostController extends GetxController {
  final PostService _service = PostService();

  final RxList<CommunityPost> _all = <CommunityPost>[].obs;
  final RxList<CommunityPost> items = <CommunityPost>[].obs;
  final RxBool isLoading = false.obs;
  final RxString status = 'All'.obs;
  final RxString search = ''.obs;

  StreamSubscription<List<CommunityPost>>? _sub;

  List<String> get statusFilters => ['All', ...CommunityPost.statuses];

  @override
  void onInit() {
    if (SupabaseConfig.isReady) {
      isLoading.value = true;
      _sub = _service.stream().listen(
        (data) {
          _all.assignAll(data);
          _applyFilters();
          isLoading.value = false;
        },
        onError: (Object e) {
          showError(friendlyError(e));
          isLoading.value = false;
        },
      );
    } else {
      load();
    }
    super.onInit();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      items.assignAll(
        await _service.fetchAll(status: status.value, query: search.value),
      );
    } catch (e) {
      showError(friendlyError(e));
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilters() {
    var list = _all.toList();
    if (status.value != 'All') {
      list = list.where((e) => e.status == status.value).toList();
    }
    final q = search.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((e) =>
              e.userName.toLowerCase().contains(q) ||
              e.description.toLowerCase().contains(q))
          .toList();
    }
    items.assignAll(list);
  }

  /// Refresh deterministically after a mutation (works even without realtime).
  Future<void> _refresh() async {
    if (SupabaseConfig.isReady) {
      _all.assignAll(await _service.fetchAll());
      _applyFilters();
    } else {
      await load();
    }
  }

  void setStatus(String value) {
    status.value = value;
    SupabaseConfig.isReady ? _applyFilters() : load();
  }

  void setSearch(String value) {
    search.value = value;
    SupabaseConfig.isReady ? _applyFilters() : load();
  }

  Future<void> changeStatus(CommunityPost post, String newStatus) async {
    try {
      await _service.updateStatus(post, newStatus);
      await _refresh();
      showSuccess('Post marked as $newStatus.');
    } catch (e) {
      showError(friendlyError(e));
    }
  }

  Future<void> delete(CommunityPost post) async {
    try {
      await _service.delete(post);
      await _refresh();
      await showSuccessDialog('Post deleted.');
    } catch (e) {
      showError(friendlyError(e));
    }
  }
}
