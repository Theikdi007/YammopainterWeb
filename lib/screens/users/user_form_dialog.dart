import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/user_controller.dart';
import '../../core/utils/ui_helpers.dart';
import '../../models/portal_user.dart';
import '../../widgets/app_text_field.dart';

class UserFormDialog extends StatefulWidget {
  const UserFormDialog({super.key, this.existing});

  final PortalUser? existing;

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _fullName = TextEditingController();
  late String _role;
  bool _saving = false;

  final UserController _controller = Get.find<UserController>();

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _email.text = e?.email ?? '';
    _fullName.text = e?.fullName ?? '';
    _role = e?.role ?? PortalUser.roles.first;
  }

  @override
  void dispose() {
    _email.dispose();
    _fullName.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    bool ok;
    if (_isEditing) {
      ok = await _controller.save(
        widget.existing!.copyWith(
          email: _email.text.trim(),
          fullName: _fullName.text.trim(),
          role: _role,
        ),
      );
    } else {
      ok = await _controller.create(
        email: _email.text.trim(),
        fullName: _fullName.text.trim(),
        role: _role,
      );
    }
    if (mounted) setState(() => _saving = false);
    if (ok) {
      Get.back<void>();
      await showSuccessDialog(
        _isEditing ? 'User updated successfully.' : 'User created successfully.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit user' : 'Create user'),
      content: SizedBox(
        width: dialogWidth(context, 420),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'Full name',
                controller: _fullName,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Email',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: 14),
              Text(
                'Role',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _role,
                items: PortalUser.roles
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e[0].toUpperCase() + e.substring(1)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _role = v!),
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
