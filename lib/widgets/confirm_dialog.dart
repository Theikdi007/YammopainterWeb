import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';

/// Shows a confirmation dialog and resolves to `true` when confirmed.
Future<bool> confirmDialog({
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  bool destructive = false,
}) async {
  final result = await Get.dialog<bool>(
    AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Get.back<bool>(result: false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          style: destructive
              ? ElevatedButton.styleFrom(backgroundColor: AppColors.danger)
              : null,
          onPressed: () => Get.back<bool>(result: true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
  return result ?? false;
}
