// Lays out every screen at mobile / tablet / desktop widths and asserts no
// overflow (or other) exceptions occur. Overflow throws a FlutterError in
// debug, which `tester.takeException()` captures.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yammopaintingweb/app/bindings/home_binding.dart';
import 'package:yammopaintingweb/controllers/auth_controller.dart';
import 'package:yammopaintingweb/controllers/nav_controller.dart';
import 'package:yammopaintingweb/screens/auth/login_screen.dart';
import 'package:yammopaintingweb/screens/home_shell.dart';
import 'package:yammopaintingweb/screens/rewards/reward_form_dialog.dart';
import 'package:yammopaintingweb/screens/svg/svg_form_dialog.dart';
import 'package:yammopaintingweb/screens/users/user_form_dialog.dart';
import 'package:yammopaintingweb/theme/app_theme.dart';
import 'package:yammopaintingweb/theme/theme_controller.dart';

const sizes = <String, Size>{
  'mobile-small': Size(360, 740),
  'mobile': Size(390, 844),
  'phablet': Size(600, 900),
  'tablet': Size(820, 1180),
  'tablet-wide': Size(1100, 800),
  'desktop': Size(1280, 800),
  'desktop-wide': Size(1680, 950),
};

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pumpAt(WidgetTester tester, Size size, Widget child) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: child,
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 600));
  }

  sizes.forEach((name, size) {
    testWidgets('Login lays out without overflow ($name)', (tester) async {
      Get.testMode = true;
      Get.put(ThemeController());
      Get.put(AuthController());

      await pumpAt(tester, size, const LoginScreen());
      expect(tester.takeException(), isNull);

      Get.reset();
    });

    testWidgets('Dashboard shell + all sections without overflow ($name)',
        (tester) async {
      Get.testMode = true;
      Get.put(ThemeController());
      Get.put(AuthController());
      HomeBinding().dependencies();
      Get.find<NavController>(); // realize lazily-registered controllers

      await pumpAt(tester, size, const HomeShell());
      expect(tester.takeException(), isNull);

      Get.reset();
    });
  });

  // Form dialogs are most at risk of horizontal overflow on narrow phones.
  const phone = Size(360, 780);
  final dialogs = <String, Widget>{
    'SVG form': const SvgFormDialog(),
    'User form': const UserFormDialog(),
    'Reward form': const RewardFormDialog(),
  };

  dialogs.forEach((label, dialog) {
    testWidgets('$label dialog fits a 360px phone', (tester) async {
      Get.testMode = true;
      HomeBinding().dependencies();
      Get.find<NavController>();

      await pumpAt(tester, phone, const Scaffold());
      // Fire (do not await — the Future resolves only when the dialog closes).
      unawaited(Get.dialog<void>(dialog));
      await tester.pumpAndSettle(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);

      Get.reset();
    });
  });
}
