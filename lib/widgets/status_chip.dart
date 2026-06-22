import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Small colored pill that communicates a status/category.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  factory StatusChip.active(bool active) => StatusChip(
        label: active ? 'Active' : 'Inactive',
        color: active ? AppColors.success : AppColors.textSecondary,
      );

  factory StatusChip.postStatus(String status) {
    final color = switch (status) {
      'active' => AppColors.success,
      'reported' => AppColors.warning,
      'removed' => AppColors.danger,
      _ => AppColors.textSecondary,
    };
    return StatusChip(label: status, color: color);
  }

  factory StatusChip.category(String category) => StatusChip(
        label: category,
        color: AppColors.category[category] ?? AppColors.primary,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
