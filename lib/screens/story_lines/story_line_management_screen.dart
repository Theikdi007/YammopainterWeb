import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/story_line_controller.dart';
import '../../core/utils/ui_helpers.dart';
import '../../models/story_line.dart';
import '../../theme/app_colors.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/content_page.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/generic_data_source.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/svg_thumbnail.dart';
import 'story_line_form_dialog.dart';

class StoryLineManagementScreen extends StatelessWidget {
  const StoryLineManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StoryLineController>();
    return ContentPage(
      title: 'Stories',
      subtitle: 'Manage stories for Drawing, Painting and Puzzle',
      actions: [
        ElevatedButton.icon(
          onPressed: () => Get.dialog<void>(const StoryLineFormDialog()),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Create Story'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Toolbar(controller: controller),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.items.isEmpty) {
                return const EmptyState(
                  icon: Icons.auto_stories_outlined,
                  message: 'No story lines found',
                  subtitle: 'Create your first story to get started.',
                );
              }
              return SingleChildScrollView(
                child: PaginatedDataTable(
                  header: Text('${controller.items.length} stories'),
                  rowsPerPage: 8,
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('Image')),
                    DataColumn(label: Text('Title')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('')),
                  ],
                  source: GenericDataSource<StoryLine>(
                    controller.items,
                    (a) => _cells(context, controller, a),
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
      BuildContext context, StoryLineController controller, StoryLine a) {
    return [
      DataCell(
        InkWell(
          onTap: () => _preview(context, a),
          child: SvgThumbnail(url: a.imageUrl, size: 40),
        ),
      ),
      DataCell(
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Text(a.title, overflow: TextOverflow.ellipsis),
        ),
      ),
      DataCell(StatusChip.category(a.category)),
      DataCell(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => Get.dialog<void>(StoryLineFormDialog(existing: a)),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () async {
              final ok = await confirmDialog(
                title: 'Delete',
                message: 'Delete "${a.title}"? This cannot be undone.',
                confirmText: 'Delete',
                destructive: true,
              );
              if (ok) controller.delete(a);
            },
          ),
        ],
      )),
    ];
  }

  void _preview(BuildContext context, StoryLine a) {
    final width = dialogWidth(context, 320);
    Get.dialog<void>(
      AlertDialog(
        title: Text(a.title),
        content: SizedBox(
          width: width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgThumbnail(url: a.imageUrl, size: width * 0.7),
              const SizedBox(height: 12),
              if (a.description.isNotEmpty) Text(a.description),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<void>(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _Toolbar extends StatefulWidget {
  const _Toolbar({required this.controller});

  final StoryLineController controller;

  @override
  State<_Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<_Toolbar> {
  final _searchCtrl = TextEditingController();

  static const double _fieldHeight = 50;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _searchField(context),
        _categoryFilter(context),
      ],
    );
  }

  Widget _searchField(BuildContext context) {
    final c = widget.controller;
    return SizedBox(
      width: 320,
      height: _fieldHeight,
      child: TextField(
        controller: _searchCtrl,
        onChanged: c.setSearch,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Search by title...',
          prefixIcon: const Icon(Icons.search_rounded,
              size: 20, color: AppColors.textSecondary),
          suffixIcon: Obx(
            () => c.search.value.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: 'Clear',
                    icon: const Icon(Icons.close_rounded, size: 18),
                    color: AppColors.textSecondary,
                    onPressed: () {
                      _searchCtrl.clear();
                      c.setSearch('');
                    },
                  ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _categoryFilter(BuildContext context) {
    final c = widget.controller;
    return Container(
      height: _fieldHeight,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.tune_rounded,
              size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Obx(
            () => DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: c.category.value,
                isDense: true,
                borderRadius: BorderRadius.circular(12),
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary),
                style: Theme.of(context).textTheme.bodyMedium,
                items: c.categoryFilters
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => c.setCategory(v!),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
