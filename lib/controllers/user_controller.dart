import 'dart:async';

import 'package:get/get.dart';

import '../core/config/supabase_config.dart';
import '../core/utils/ui_helpers.dart';
import '../models/portal_user.dart';
import '../services/user_service.dart';

class UserController extends GetxController {
  final UserService _service = UserService();

  final RxList<PortalUser> _all = <PortalUser>[].obs;
  final RxList<PortalUser> items = <PortalUser>[].obs;
  final RxBool isLoading = false.obs;
  final RxString search = ''.obs;

  StreamSubscription<List<PortalUser>>? _sub;

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
      items.assignAll(await _service.fetchAll(query: search.value));
    } catch (e) {
      showError(friendlyError(e));
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilters() {
    final q = search.value.trim().toLowerCase();
    items.assignAll(q.isEmpty
        ? _all
        : _all.where((e) =>
            e.email.toLowerCase().contains(q) ||
            e.fullName.toLowerCase().contains(q)));
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

  void setSearch(String value) {
    search.value = value;
    SupabaseConfig.isReady ? _applyFilters() : load();
  }

  Future<bool> create({
    required String email,
    required String fullName,
    required String role,
  }) async {
    try {
      await _service.create(email: email, fullName: fullName, role: role);
      await _refresh();
      return true;
    } catch (e) {
      showError(friendlyError(e));
      return false;
    }
  }

  Future<bool> save(PortalUser user) async {
    try {
      await _service.update(user);
      await _refresh();
      return true;
    } catch (e) {
      showError(friendlyError(e));
      return false;
    }
  }

  Future<void> changeRole(PortalUser user, String role) async {
    try {
      await _service.updateRole(user, role);
      await _refresh();
      showSuccess('Role updated to $role.');
    } catch (e) {
      showError(friendlyError(e));
    }
  }

  Future<void> toggleActive(PortalUser user, bool value) async {
    try {
      await _service.setActive(user, value);
      await _refresh();
    } catch (e) {
      showError(friendlyError(e));
    }
  }

  Future<void> delete(PortalUser user) async {
    try {
      await _service.delete(user);
      await _refresh();
      await showSuccessDialog('User deleted.');
    } catch (e) {
      showError(friendlyError(e));
    }
  }
}
