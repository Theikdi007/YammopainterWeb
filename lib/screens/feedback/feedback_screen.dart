import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/feedback_controller.dart';
import '../../core/utils/ui_helpers.dart';
import '../../models/feedback_entry.dart';
import '../../theme/app_colors.dart';
import '../../widgets/content_page.dart';
import '../../widgets/empty_state.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FeedbackController>();
    return ContentPage(
      title: 'Feedback',
      subtitle: 'What users tell us from inside the mobile app',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Obx(() => _filterDropdown(
                    label: 'Category',
                    value: controller.category.value,
                    options: controller.categoryFilters,
                    onChanged: controller.setCategory,
                  )),
              Obx(() => _filterDropdown(
                    label: 'Sentiment',
                    value: controller.sentiment.value,
                    options: controller.sentimentFilters,
                    onChanged: controller.setSentiment,
                  )),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.items.isEmpty) {
                return const EmptyState(
                  icon: Icons.forum_outlined,
                  message: 'No feedback yet',
                  subtitle: 'User feedback from the app will appear here.',
                );
              }
              return ListView.separated(
                itemCount: controller.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _card(context, controller.items[i]),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _filterDropdown({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label:  '),
        DropdownButton<String>(
          value: value,
          borderRadius: BorderRadius.circular(12),
          items: options
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e == 'All' ? 'All' : _capitalize(e)),
                  ))
              .toList(),
          onChanged: (v) => onChanged(v!),
        ),
      ],
    );
  }

  Widget _card(BuildContext context, FeedbackEntry f) {
    final color = _categoryColor(f.category);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              child: Text(
                _sentimentEmoji(f.sentiment),
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _badge(_capitalize(f.category), color),
                      if (f.platform != null && f.platform!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        _badge(f.platform!.toUpperCase(), AppColors.info),
                      ],
                      const Spacer(),
                      Text(
                        formatDateTime(f.createdAt),
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    f.message.isEmpty ? '(no message)' : f.message,
                    style: const TextStyle(height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _metaLine(f),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  static String _metaLine(FeedbackEntry f) {
    final parts = <String>['User ${_shortId(f.userId)}'];
    if (f.appVersion != null && f.appVersion!.isNotEmpty) {
      parts.add('v${f.appVersion}');
    }
    return parts.join('  •  ');
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  static String _shortId(String id) =>
      id.length <= 8 ? id : '${id.substring(0, 8)}…';

  static Color _categoryColor(String category) {
    switch (category) {
      case 'bug':
        return AppColors.danger;
      case 'suggestion':
        return AppColors.info;
      case 'praise':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  static String _sentimentEmoji(String? sentiment) {
    switch (sentiment) {
      case 'happy':
        return '😍';
      case 'neutral':
        return '😐';
      case 'sad':
        return '😞';
      default:
        return '💬';
    }
  }
}
