import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import 'app_routes.dart';

/// Blocks protected routes when no admin is signed in.
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthController>();
    if (!auth.loggedIn.value) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}

/// Sends already-authenticated admins straight to the dashboard.
class GuestMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthController>();
    if (auth.loggedIn.value) {
      return const RouteSettings(name: AppRoutes.home);
    }
    return null;
  }
}
