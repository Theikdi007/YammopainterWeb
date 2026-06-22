import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Holds the active [ThemeMode] and toggles between light and dark.
class ThemeController extends GetxController {
  final Rx<ThemeMode> mode = ThemeMode.light.obs;

  bool get isDark => mode.value == ThemeMode.dark;

  void toggle() {
    mode.value = isDark ? ThemeMode.light : ThemeMode.dark;
    Get.changeThemeMode(mode.value);
  }
}
