import 'package:get/get.dart';

import '../../controllers/dashboard_controller.dart';
import '../../controllers/feedback_controller.dart';
import '../../controllers/nav_controller.dart';
import '../../controllers/notification_controller.dart';
import '../../controllers/post_controller.dart';
import '../../controllers/reward_controller.dart';
import '../../controllers/story_line_controller.dart';
import '../../controllers/svg_controller.dart';
import '../../controllers/user_controller.dart';

/// Lazily instantiates every feature controller used inside the dashboard shell.
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NavController(), fenix: true);
    Get.lazyPut(() => DashboardController(), fenix: true);
    Get.lazyPut(() => SvgController(), fenix: true);
    Get.lazyPut(() => StoryLineController(), fenix: true);
    Get.lazyPut(() => UserController(), fenix: true);
    Get.lazyPut(() => NotificationController(), fenix: true);
    Get.lazyPut(() => RewardController(), fenix: true);
    Get.lazyPut(() => PostController(), fenix: true);
    Get.lazyPut(() => FeedbackController(), fenix: true);
  }
}
