import 'dart:async';
import 'dart:typed_data';

import 'package:get/get.dart';

import '../core/config/supabase_config.dart';
import '../core/utils/ui_helpers.dart';
import '../models/story_line.dart';
import '../services/story_line_service.dart';

class StoryLineController extends GetxController {
  final StoryLineService _service = StoryLineService();

  final RxList<StoryLine> _all = <StoryLine>[].obs;
  final RxList<StoryLine> items = <StoryLine>[].obs;
  final RxBool isLoading = false.obs;
  final RxString category = 'All'.obs;
  final RxString search = ''.obs;

  StreamSubscription<List<StoryLine>>? _sub;

  List<String> get categoryFilters => ['All', ...StoryLine.categories];

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
        await _service.fetchAll(category: category.value, query: search.value),
      );
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
    final q = search.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((e) => e.title.toLowerCase().contains(q)).toList();
    }
    items.assignAll(list);
  }

  Future<void> _refresh() async {
    if (SupabaseConfig.isReady) {
      _all.assignAll(await _service.fetchAll());
      _applyFilters();
    } else {
      await load();
    }
  }

  void setCategory(String value) {
    category.value = value;
    SupabaseConfig.isReady ? _applyFilters() : load();
  }

  void setSearch(String value) {
    search.value = value;
    SupabaseConfig.isReady ? _applyFilters() : load();
  }

  Future<bool> create({
    required String title,
    required String description,
    required String category,
    required String targetApp,
    required Uint8List bytes,
    required String fileName,
    DateTime? date,
  }) async {
    try {
      await _service.create(
        title: title,
        description: description,
        category: category,
        targetApp: targetApp,
        bytes: bytes,
        fileName: fileName,
        date: date,
      );
      await _refresh();
      return true;
    } catch (e) {
      showError(friendlyError(e));
      return false;
    }
  }

  Future<bool> save(
    StoryLine story, {
    Uint8List? bytes,
    String? fileName,
  }) async {
    try {
      await _service.update(story, bytes: bytes, fileName: fileName);
      await _refresh();
      return true;
    } catch (e) {
      showError(friendlyError(e));
      return false;
    }
  }

  Future<void> toggleActive(StoryLine story, bool value) async {
    try {
      await _service.setActive(story, value);
      await _refresh();
    } catch (e) {
      showError(friendlyError(e));
    }
  }

  Future<void> delete(StoryLine story) async {
    try {
      await _service.delete(story);
      await _refresh();
      await showSuccessDialog('Story deleted.');
    } catch (e) {
      showError(friendlyError(e));
    }
  }
}
