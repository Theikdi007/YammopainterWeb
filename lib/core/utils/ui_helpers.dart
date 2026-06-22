import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../theme/app_colors.dart';

/// Shared snackbars + formatting helpers used across controllers and screens.

void showSuccess(String message, {String title = 'Success'}) {
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: AppColors.success,
    colorText: Colors.white,
    margin: const EdgeInsets.all(16),
    borderRadius: 12,
    icon: const Icon(Icons.check_circle_outline, color: Colors.white),
    duration: const Duration(seconds: 3),
  );
}

/// A blocking success popup with an OK button. Resolves when OK is pressed.
Future<void> showSuccessDialog(String message, {String title = 'Success'}) {
  return Get.dialog<void>(
    AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success),
          const SizedBox(width: 10),
          Text(title),
        ],
      ),
      content: Text(message),
      actions: [
        ElevatedButton(
          onPressed: () => Get.back<void>(),
          child: const Text('OK'),
        ),
      ],
    ),
    barrierDismissible: false,
  );
}

void showError(String message, {String title = 'Something went wrong'}) {
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: AppColors.danger,
    colorText: Colors.white,
    margin: const EdgeInsets.all(16),
    borderRadius: 12,
    icon: const Icon(Icons.error_outline, color: Colors.white),
    duration: const Duration(seconds: 4),
  );
}

String friendlyError(Object error) {
  final text = error.toString();
  return text.replaceFirst('Exception: ', '');
}

/// Width for dialog content that never exceeds the screen on small devices.
/// AlertDialog reserves 40px inset on each side, so we cap at width - 80.
double dialogWidth(BuildContext context, [double max = 460]) {
  final available = MediaQuery.sizeOf(context).width - 80;
  return available.clamp(0.0, max);
}

final DateFormat _dateFmt = DateFormat('MMM d, yyyy');
final DateFormat _dateTimeFmt = DateFormat('MMM d, yyyy • h:mm a');

String formatDate(DateTime date) => _dateFmt.format(date.toLocal());
String formatDateTime(DateTime date) => _dateTimeFmt.format(date.toLocal());
