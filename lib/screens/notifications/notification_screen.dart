import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/notification_controller.dart';
import '../../core/utils/ui_helpers.dart';
import '../../models/app_notification.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/content_page.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/section_card.dart';
import '../../layout/responsive.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _body = TextEditingController();
  final _targetValue = TextEditingController();
  String _target = AppNotification.targets.first;

  final NotificationController _controller = Get.find<NotificationController>();

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _targetValue.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await _controller.send(
      title: _title.text.trim(),
      body: _body.text.trim(),
      target: _target,
      targetValue: _targetValue.text.trim(),
    );
    if (ok) {
      _title.clear();
      _body.clear();
      _targetValue.clear();
      setState(() => _target = AppNotification.targets.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentPage(
      title: 'Notifications',
      subtitle: 'Send push notifications and review history',
      child: ResponsiveLayout(
        mobile: ListView(
          children: [
            _form(context),
            const SizedBox(height: 16),
            _history(context),
          ],
        ),
        desktop: SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 380, child: _form(context)),
              const SizedBox(width: 16),
              Expanded(child: _history(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _form(BuildContext context) {
    return SectionCard(
      title: 'Create notification',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              label: 'Title',
              controller: _title,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            AppTextField(
              label: 'Message',
              controller: _body,
              maxLines: 4,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            Text(
              'Target',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _target,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All users')),
                DropdownMenuItem(value: 'user', child: Text('Specific user')),
                DropdownMenuItem(value: 'group', child: Text('Group')),
              ],
              onChanged: (v) => setState(() => _target = v!),
            ),
            if (_target != 'all') ...[
              const SizedBox(height: 14),
              AppTextField(
                label: _target == 'user' ? 'User email / ID' : 'Group name',
                controller: _targetValue,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
            ],
            const SizedBox(height: 20),
            Obx(
              () => SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _controller.isSending.value ? null : _send,
                  icon: _controller.isSending.value
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.2, color: Colors.white),
                        )
                      : const Icon(Icons.send, size: 18),
                  label: const Text('Send notification'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _history(BuildContext context) {
    return SectionCard(
      title: 'History',
      child: Obx(() {
        if (_controller.isLoading.value) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (_controller.items.isEmpty) {
          return const EmptyState(
            icon: Icons.notifications_off_outlined,
            message: 'No notifications sent yet',
          );
        }
        return Column(
          children: _controller.items.map((n) => _tile(context, n)).toList(),
        );
      }),
    );
  }

  Widget _tile(BuildContext context, AppNotification n) {
    final sent = n.status == 'sent';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        tileColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: CircleAvatar(
          backgroundColor:
              (sent ? AppColors.success : AppColors.danger).withValues(alpha: 0.15),
          child: Icon(
            sent ? Icons.check : Icons.error_outline,
            color: sent ? AppColors.success : AppColors.danger,
            size: 20,
          ),
        ),
        title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(n.body),
            const SizedBox(height: 4),
            Text(
              'To: ${_targetLabel(n)} • ${formatDateTime(n.sentAt)}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  String _targetLabel(AppNotification n) {
    return switch (n.target) {
      'all' => 'All users',
      'user' => 'User ${n.targetValue}',
      'group' => 'Group ${n.targetValue}',
      _ => n.target,
    };
  }
}
