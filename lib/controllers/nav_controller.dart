import 'package:get/get.dart';

import 'dashboard_controller.dart';

/// Tracks the selected section inside the dashboard shell.
class NavController extends GetxController {
  /// Index of the Dashboard destination in `navItems`.
  static const dashboardIndex = 0;

  final RxInt index = 0.obs;

  void select(int value) {
    index.value = value;
    // Re-opening the dashboard silently refreshes every section, so the overview
    // reflects changes made elsewhere even when realtime is off on some tables.
    if (value == dashboardIndex && Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().load(silent: true);
    }
  }
}
