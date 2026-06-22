import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/dashboard_controller.dart';
import '../core/utils/ui_helpers.dart';
import '../layout/responsive.dart';
import '../theme/app_colors.dart';
import '../widgets/content_page.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/status_chip.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    return ContentPage(
      title: 'Dashboard',
      subtitle: 'Overview of your apps content and community',
      actions: [
        OutlinedButton.icon(
          onPressed: controller.load,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Refresh'),
        ),
      ],
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final columns = Responsive.valueColumns(context);
        final cards = [
          StatCard(
            title: 'Image Assets',
            value: '${controller.svgCount.value}',
            icon: Icons.image_outlined,
            color: AppColors.primary,
          ),
          StatCard(
            title: 'Users',
            value: '${controller.userCount.value}',
            icon: Icons.people_outline,
            color: AppColors.info,
          ),
          StatCard(
            title: 'Community Posts',
            value: '${controller.postCount.value}',
            icon: Icons.dynamic_feed_outlined,
            color: AppColors.accent,
          ),
          StatCard(
            title: 'Active Rewards',
            value: '${controller.activeRewards.value}',
            icon: Icons.card_giftcard_outlined,
            color: AppColors.secondary,
          ),
        ];
        return ListView(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              // Fixed pixel height per card → never depends on width, so it can
              // never be measured too short for its text.
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                mainAxisExtent: 96,
              ),
              itemCount: cards.length,
              itemBuilder: (context, i) => cards[i],
            ),
            const SizedBox(height: 16),
            _byCategoryCard(context, controller),
            const SizedBox(height: 16),
            ResponsiveLayout(
              mobile: Column(
                children: [
                  _recentNotifications(context, controller),
                  const SizedBox(height: 16),
                  _recentPosts(context, controller),
                ],
              ),
              desktop: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _recentNotifications(context, controller)),
                  const SizedBox(width: 16),
                  Expanded(child: _recentPosts(context, controller)),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _byCategoryCard(BuildContext context, DashboardController c) {
    return SectionCard(
      title: 'Image assets by category',
      child: SvgCategoriesView(map: c.svgByCategory),
    );
  }

  Widget _recentNotifications(BuildContext context, DashboardController c) {
    return SectionCard(
      title: 'Recent notifications',
      child: c.recentNotifications.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_off_outlined,
              message: 'No notifications yet',
            )
          : Column(
              children: c.recentNotifications
                  .map(
                    (n) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.campaign_outlined,
                            color: Colors.white, size: 20),
                      ),
                      title: Text(n.title),
                      subtitle: Text(
                        n.body,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        formatDate(n.sentAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }

  Widget _recentPosts(BuildContext context, DashboardController c) {
    return SectionCard(
      title: 'Recent community posts',
      child: c.recentPosts.isEmpty
          ? const EmptyState(
              icon: Icons.dynamic_feed_outlined,
              message: 'No posts yet',
            )
          : Column(
              children: c.recentPosts
                  .map(
                    (p) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.accent,
                        child: Icon(Icons.person_outline,
                            color: Colors.white, size: 20),
                      ),
                      title: Text(p.userName),
                      subtitle: Text(
                        p.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: StatusChip.postStatus(p.status),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

/// Renders a simple labelled bar per SVG category.
class SvgCategoriesView extends StatelessWidget {
  const SvgCategoriesView({super.key, required this.map});

  final Map<String, int> map;

  @override
  Widget build(BuildContext context) {
    if (map.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text('No image assets yet.'),
      );
    }
    final total = map.values.fold<int>(0, (a, b) => a + b);
    return Column(
      children: map.entries.map((e) {
        final color = AppColors.category[e.key] ?? AppColors.primary;
        final fraction = total == 0 ? 0.0 : e.value / total;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key,
                      style: Theme.of(context).textTheme.bodyMedium),
                  Text('${e.value}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: fraction,
                  minHeight: 8,
                  backgroundColor: color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
