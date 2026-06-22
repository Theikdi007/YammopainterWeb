import 'dart:async';
import 'dart:typed_data';

import 'package:get/get.dart';

import '../core/config/supabase_config.dart';
import '../core/utils/ui_helpers.dart';
import '../models/svg_asset.dart';
import '../services/svg_service.dart';

class SvgController extends GetxController {
  final SvgService _service = SvgService();

  /// Full set from the realtime stream; [items] is the filtered view.
  final RxList<SvgAsset> _all = <SvgAsset>[].obs;
  final RxList<SvgAsset> items = <SvgAsset>[].obs;
  final RxBool isLoading = false.obs;
  final RxString category = 'All'.obs;
  final RxString search = ''.obs;

  StreamSubscription<List<SvgAsset>>? _sub;

  List<String> get categoryFilters => ['All', ...SvgAsset.categories];

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

  /// One-shot load (demo mode / manual refresh).
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
      list = list.where((e) => e.name.toLowerCase().contains(q)).toList();
    }
    items.assignAll(list);
  }

  /// After a mutation, refresh deterministically so the acting client updates
  /// immediately even when realtime isn't enabled on the table. (Realtime still
  /// pushes live updates to *other* clients.)
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
    required String name,
    required String description,
    required String category,
    required String targetApp,
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      await _service.create(
        name: name,
        description: description,
        category: category,
        targetApp: targetApp,
        bytes: bytes,
        fileName: fileName,
      );
      await _refresh();
      return true;
    } catch (e) {
      showError(friendlyError(e));
      return false;
    }
  }

  Future<bool> save(
    SvgAsset asset, {
    Uint8List? bytes,
    String? fileName,
  }) async {
    try {
      await _service.update(asset, bytes: bytes, fileName: fileName);
      await _refresh();
      return true;
    } catch (e) {
      showError(friendlyError(e));
      return false;
    }
  }

  Future<void> toggleActive(SvgAsset asset, bool value) async {
    try {
      await _service.setActive(asset, value);
      await _refresh();
    } catch (e) {
      showError(friendlyError(e));
    }
  }

  Future<void> delete(SvgAsset asset) async {
    try {
      await _service.delete(asset);
      await _refresh();
      await showSuccessDialog('Image deleted.');
    } catch (e) {
      showError(friendlyError(e));
    }
  }
}
