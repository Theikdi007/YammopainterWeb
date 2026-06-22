import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/reward_controller.dart';
import '../../core/utils/ui_helpers.dart';
import '../../models/reward.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/content_page.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/generic_data_source.dart';
import '../../widgets/status_chip.dart';
import 'reward_form_dialog.dart';

class RewardScreen extends StatelessWidget {
  const RewardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RewardController>();
    return DefaultTabController(
      length: 2,
      child: ContentPage(
        title: 'Rewards',
        subtitle: 'Configure rewards and track user grants',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(text: 'Rewards'),
                Tab(text: 'User Rewards'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                children: [
                  _RewardsTab(controller: controller),
                  _UserRewardsTab(controller: controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardsTab extends StatelessWidget {
  const _RewardsTab({required this.controller});

  final RewardController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton.icon(
            onPressed: () => Get.dialog<void>(const RewardFormDialog()),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Reward'),
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
                icon: Icons.card_giftcard_outlined,
                message: 'No rewards configured',
              );
            }
            return SingleChildScrollView(
              child: PaginatedDataTable(
                header: Text('${controller.items.length} rewards'),
                rowsPerPage: 8,
                columnSpacing: 24,
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Points')),
                  DataColumn(label: Text('Active')),
                  DataColumn(label: Text('Created')),
                  DataColumn(label: Text('Actions')),
                ],
                source: GenericDataSource<Reward>(
                  controller.items,
                  (r) => _cells(context, r),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  List<DataCell> _cells(BuildContext context, Reward r) {
    return [
      DataCell(ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 200),
        child: Text(r.name, overflow: TextOverflow.ellipsis),
      )),
      DataCell(StatusChip.category(r.type)),
      DataCell(Text('${r.points}')),
      DataCell(Switch(
        value: r.isActive,
        onChanged: (v) => controller.toggleActive(r, v),
      )),
      DataCell(Text(formatDate(r.createdAt))),
      DataCell(Row(
        children: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => Get.dialog<void>(RewardFormDialog(existing: r)),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () async {
              final ok = await confirmDialog(
                title: 'Delete reward',
                message: 'Delete "${r.name}"?',
                confirmText: 'Delete',
                destructive: true,
              );
              if (ok) controller.delete(r);
            },
          ),
        ],
      )),
    ];
  }
}

class _UserRewardsTab extends StatelessWidget {
  const _UserRewardsTab({required this.controller});

  final RewardController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 280,
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search by user or reward...',
              prefixIcon: Icon(Icons.search, size: 20),
            ),
            onChanged: controller.setUserRewardSearch,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Obx(() {
            if (controller.isLoadingUserRewards.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.userRewards.isEmpty) {
              return const EmptyState(
                icon: Icons.emoji_events_outlined,
                message: 'No user rewards yet',
              );
            }
            return SingleChildScrollView(
              child: PaginatedDataTable(
                header: Text('${controller.userRewards.length} grants'),
                rowsPerPage: 8,
                columnSpacing: 24,
                columns: const [
                  DataColumn(label: Text('User')),
                  DataColumn(label: Text('Reward')),
                  DataColumn(label: Text('Points')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Awarded')),
                ],
                source: GenericDataSource<UserReward>(
                  controller.userRewards,
                  (ur) => [
                    DataCell(Text(ur.userEmail)),
                    DataCell(Text(ur.rewardName)),
                    DataCell(Text('${ur.points}')),
                    DataCell(StatusChip(
                      label: ur.status,
                      color: ur.status == 'redeemed'
                          ? Colors.deepPurple
                          : Colors.teal,
                    )),
                    DataCell(Text(formatDate(ur.awardedAt))),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
