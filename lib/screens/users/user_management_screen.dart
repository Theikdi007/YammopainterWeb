import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/user_controller.dart';
import '../../core/utils/ui_helpers.dart';
import '../../models/portal_user.dart';
import '../../theme/app_colors.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/content_page.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/generic_data_source.dart';
import '../../widgets/status_chip.dart';
import 'user_form_dialog.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();
    return ContentPage(
      title: 'User Management',
      subtitle: 'Portal admins and editors',
      actions: [
        ElevatedButton.icon(
          onPressed: () => Get.dialog<void>(const UserFormDialog()),
          icon: const Icon(Icons.person_add_alt, size: 18),
          label: const Text('Add User'),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 280,
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search name or email...',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
              onChanged: controller.setSearch,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.items.isEmpty) {
                return const EmptyState(
                  icon: Icons.people_outline,
                  message: 'No users found',
                );
              }
              return SingleChildScrollView(
                child: PaginatedDataTable(
                  header: Text('${controller.items.length} users'),
                  rowsPerPage: 8,
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Role')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Created')),
                    DataColumn(label: Text('Actions')),
                  ],
                  source: GenericDataSource<PortalUser>(
                    controller.items,
                    (u) => _cells(context, controller, u),
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
      BuildContext context, UserController controller, PortalUser u) {
    return [
      DataCell(Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(
              u.fullName.isNotEmpty ? u.fullName[0].toUpperCase() : '?',
              style: const TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 10),
          Text(u.fullName),
        ],
      )),
      DataCell(Text(u.email)),
      DataCell(
        DropdownButton<String>(
          value: u.role,
          underline: const SizedBox.shrink(),
          items: PortalUser.roles
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e[0].toUpperCase() + e.substring(1)),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null && v != u.role) controller.changeRole(u, v);
          },
        ),
      ),
      DataCell(StatusChip.active(u.isActive)),
      DataCell(Text(formatDate(u.createdAt))),
      DataCell(Row(
        children: [
          Switch(
            value: u.isActive,
            onChanged: (v) => controller.toggleActive(u, v),
          ),
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => Get.dialog<void>(UserFormDialog(existing: u)),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () async {
              final ok = await confirmDialog(
                title: 'Delete user',
                message: 'Delete "${u.email}"?',
                confirmText: 'Delete',
                destructive: true,
              );
              if (ok) controller.delete(u);
            },
          ),
        ],
      )),
    ];
  }
}
