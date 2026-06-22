import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/reward_controller.dart';
import '../../core/utils/ui_helpers.dart';
import '../../models/reward.dart';
import '../../widgets/app_text_field.dart';

class RewardFormDialog extends StatefulWidget {
  const RewardFormDialog({super.key, this.existing});

  final Reward? existing;

  @override
  State<RewardFormDialog> createState() => _RewardFormDialogState();
}

class _RewardFormDialogState extends State<RewardFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _points = TextEditingController();
  late String _type;
  bool _saving = false;

  final RewardController _controller = Get.find<RewardController>();

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name.text = e?.name ?? '';
    _description.text = e?.description ?? '';
    _points.text = (e?.points ?? 0).toString();
    _type = e?.type ?? Reward.types.first;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _points.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final points = int.tryParse(_points.text.trim()) ?? 0;

    bool ok;
    if (_isEditing) {
      ok = await _controller.save(
        widget.existing!.copyWith(
          name: _name.text.trim(),
          description: _description.text.trim(),
          points: points,
          type: _type,
        ),
      );
    } else {
      ok = await _controller.create(
        name: _name.text.trim(),
        description: _description.text.trim(),
        points: points,
        type: _type,
      );
    }
    if (mounted) setState(() => _saving = false);
    if (ok) {
      Get.back<void>();
      await showSuccessDialog(
        _isEditing
            ? 'Reward updated successfully.'
            : 'Reward created successfully.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit reward' : 'Create reward'),
      content: SizedBox(
        width: dialogWidth(context, 420),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'Name',
                controller: _name,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Description',
                controller: _description,
                maxLines: 3,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Points',
                controller: _points,
                keyboardType: TextInputType.number,
                validator: (v) =>
                    (v == null || int.tryParse(v.trim()) == null)
                        ? 'Enter a number'
                        : null,
              ),
              const SizedBox(height: 14),
              Text(
                'Type',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _type,
                items: Reward.types
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e[0].toUpperCase() + e.substring(1)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _type = v!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Get.back<void>(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.2, color: Colors.white),
                )
              : Text(_isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }
}
