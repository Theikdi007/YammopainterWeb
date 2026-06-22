import 'dart:async';
import 'package:get/get.dart';

import '../core/config/supabase_config.dart';
import '../core/utils/ui_helpers.dart';
import '../models/feedback_entry.dart';
import '../services/feedback_service.dart';

class FeedbackController extends GetxController {
  final FeedbackService _service = FeedbackService();

  final RxList<FeedbackEntry> _all = <FeedbackEntry>[].obs; // full dataset
  final RxList<FeedbackEntry> items = <FeedbackEntry>[].obs; // filtered view
  final RxBool isLoading = false.obs;
  final RxString category = 'All'.obs;
  final RxString sentiment = 'All'.obs;

  StreamSubscription<List<FeedbackEntry>>? _sub;

  List<String> get categoryFilters => ['All', ...FeedbackEntry.categories];
  List<String> get sentimentFilters => ['All', ...FeedbackEntry.sentiments];

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
      _all.assignAll(await _service.fetchAll());
      _applyFilters();
    } catch (e) {
      showError(friendlyError(e));
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilters() {
    var list = _all.toList();
    if (category.value != 'All') {
      list = list.where((e) => e.category == category.value).toList();
    }
    if (sentiment.value != 'All') {
      list = list.where((e) => e.sentiment == sentiment.value).toList();
    }
    items.assignAll(list);
  }

  void setCategory(String value) {
    category.value = value;
    _applyFilters();
  }

  void setSentiment(String value) {
    sentiment.value = value;
    _applyFilters();
  }
}
