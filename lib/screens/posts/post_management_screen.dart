import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/post_controller.dart';
import '../../core/utils/ui_helpers.dart';
import '../../models/community_post.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/content_page.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/generic_data_source.dart';
import '../../widgets/status_chip.dart';
import 'post_detail_screen.dart';

class PostManagementScreen extends StatelessWidget {
  const PostManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostController>();
    return ContentPage(
      title: 'Community Posts',
      subtitle: 'Moderate user-generated content',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 280,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search posts...',
                    prefixIcon: Icon(Icons.search, size: 20),
                  ),
                  onChanged: controller.setSearch,
                ),
              ),
              Obx(
                () => DropdownButton<String>(
                  value: controller.status.value,
                  borderRadius: BorderRadius.circular(12),
                  items: controller.statusFilters
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => controller.setStatus(v!),
                ),
              ),
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
                  icon: Icons.dynamic_feed_outlined,
                  message: 'No posts found',
                );
              }
              return SingleChildScrollView(
                child: PaginatedDataTable(
                  header: Text('${controller.items.length} posts'),
                  rowsPerPage: 8,
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('Author')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Likes')),
                    DataColumn(label: Text('Comments')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Created')),
                    DataColumn(label: Text('Actions')),
                  ],
                  source: GenericDataSource<CommunityPost>(
                    controller.items,
                    (p) => _cells(context, controller, p),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  List<DataCell> _cells(
      BuildContext context, PostController controller, CommunityPost p) {
    return [
      DataCell(Text(p.userName)),
      DataCell(ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 260),
        child: Text(p.description, overflow: TextOverflow.ellipsis),
      )),
      DataCell(Text('${p.likes}')),
      DataCell(Text('${p.comments}')),
      DataCell(StatusChip.postStatus(p.status)),
      DataCell(Text(formatDate(p.createdAt))),
      DataCell(Row(
        children: [
          IconButton(
            tooltip: 'View details',
            icon: const Icon(Icons.open_in_new, size: 20),
            onPressed: () => Get.to<void>(() => PostDetailScreen(post: p)),
          ),
          PopupMenuButton<String>(
            tooltip: 'Moderate',
            icon: const Icon(Icons.more_vert, size: 20),
            onSelected: (value) {
              if (value == 'delete') {
                _confirmDelete(controller, p);
              } else {
                controller.changeStatus(p, value);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'active', child: Text('Mark active')),
              PopupMenuItem(value: 'reported', child: Text('Mark reported')),
              PopupMenuItem(value: 'removed', child: Text('Mark removed')),
              PopupMenuDivider(),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      )),
    ];
  }

  Future<void> _confirmDelete(
      PostController controller, CommunityPost p) async {
    final ok = await confirmDialog(
      title: 'Delete post',
      message: 'Permanently delete this post by ${p.userName}?',
      confirmText: 'Delete',
      destructive: true,
    );
    if (ok) controller.delete(p);
  }
}
