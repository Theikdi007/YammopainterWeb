import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/post_controller.dart';
import '../../core/utils/ui_helpers.dart';
import '../../models/community_post.dart';
import '../../theme/app_colors.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_chip.dart';

class PostDetailScreen extends StatelessWidget {
  const PostDetailScreen({super.key, required this.post});

  final CommunityPost post;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Post details')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            AppColors.accent.withValues(alpha: 0.15),
                        child: const Icon(Icons.person_outline,
                            color: AppColors.accent),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post.userName,
                                style: Theme.of(context).textTheme.titleMedium),
                            Text(
                              post.userEmail,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      StatusChip.postStatus(post.status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 10,
                      child: Image.network(
                        post.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: AppColors.lightBorder,
                          child: const Icon(Icons.broken_image_outlined,
                              size: 48),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(post.description,
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _stat(Icons.favorite_border, '${post.likes} likes'),
                      const SizedBox(width: 20),
                      _stat(Icons.mode_comment_outlined,
                          '${post.comments} comments'),
                      const Spacer(),
                      Text(formatDateTime(post.createdAt),
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  const Divider(height: 32),
                  Text('Moderation',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          controller.changeStatus(post, 'active');
                          Get.back<void>();
                        },
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text('Approve'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          controller.changeStatus(post, 'reported');
                          Get.back<void>();
                        },
                        icon: const Icon(Icons.flag_outlined, size: 18),
                        label: const Text('Flag as reported'),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.danger),
                        onPressed: () async {
                          final ok = await confirmDialog(
                            title: 'Delete post',
                            message: 'Permanently delete this post?',
                            confirmText: 'Delete',
                            destructive: true,
                          );
                          if (ok) {
                            controller.delete(post);
                            Get.back<void>();
                          }
                        },
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stat(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
