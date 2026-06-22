import 'dart:async';

import 'package:get/get.dart';

import '../core/config/supabase_config.dart';
import '../core/utils/ui_helpers.dart';
import '../models/app_notification.dart';
import '../services/notification_service.dart';
import 'dashboard_controller.dart';

class NotificationController extends GetxController {
  final NotificationService _service = NotificationService();

  final RxList<AppNotification> items = <AppNotification>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;

  StreamSubscription<List<AppNotification>>? _sub;

  @override
  void onInit() {
    if (SupabaseConfig.isReady) {
      isLoading.value = true;
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
      items.assignAll(await _service.fetchAll());
    } catch (e) {
      showError(friendlyError(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> send({
    required String title,
    required String body,
    required String target,
    String targetValue = '',
  }) async {
    isSending.value = true;
    try {
      await _service.send(
        title: title,
        body: body,
        target: target,
        targetValue: targetValue,
      );
      // Always refresh so the new entry shows immediately, even when realtime
      // isn't enabled on the notifications table.
      await load();
      // Keep the dashboard's "Recent notifications" in sync too — its realtime
      // stream won't fire when realtime is disabled on the table.
      if (Get.isRegistered<DashboardController>()) {
        await Get.find<DashboardController>().load();
      }
      await showSuccessDialog('Notification sent successfully.');
      return true;
    } catch (e) {
      showError(friendlyError(e));
      return false;
    } finally {
      isSending.value = false;
    }
  }
}
