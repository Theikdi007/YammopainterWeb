import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/story_line_controller.dart';
import '../../core/utils/image_formats.dart';
import '../../core/utils/ui_helpers.dart';
import '../../models/story_line.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/svg_thumbnail.dart';

class StoryLineFormDialog extends StatefulWidget {
  const StoryLineFormDialog({super.key, this.existing});

  final StoryLine? existing;

  @override
  State<StoryLineFormDialog> createState() => _StoryLineFormDialogState();
}

class _StoryLineFormDialogState extends State<StoryLineFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();

  late String _category;
  late String _targetApp;

  Uint8List? _bytes;
  String? _fileName;
  bool _saving = false;

  final StoryLineController _controller = Get.find<StoryLineController>();

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title.text = e?.title ?? '';
    _description.text = e?.description ?? '';
    _category = e?.category ?? StoryLine.categories.first;
    _targetApp = e?.targetApp ?? StoryLine.apps.first;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: kAllowedImageExtensions,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        _bytes = file.bytes;
        _fileName = file.name;
      });
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_isEditing && _bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose an image file.')),
      );
      return;
    }
    setState(() => _saving = true);

    bool ok;
    if (_isEditing) {
      ok = await _controller.save(
        widget.existing!.copyWith(
          title: _title.text.trim(),
          description: _description.text.trim(),
          category: _category,
          targetApp: _targetApp,
        ),
        bytes: _bytes,
        fileName: _fileName,
      );
    } else {
      ok = await _controller.create(
        title: _title.text.trim(),
        description: _description.text.trim(),
        category: _category,
        targetApp: _targetApp,
        bytes: _bytes!,
        fileName: _fileName!,
      );
    }
    if (mounted) setState(() => _saving = false);
    if (ok) {
      Get.back<void>();
      await showSuccessDialog(
        _isEditing
            ? 'Story updated successfully.'
            : 'Story created successfully.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Story' : 'Create Story'),
      content: SizedBox(
        width: dialogWidth(context),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _filePicker(context),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Title',
                  controller: _title,
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
                _dropdown(
                  label: 'Category',
                  value: _category,
                  items: StoryLine.categories,
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 14),
                _dropdown(
                  label: 'Target app',
                  value: _targetApp,
                  items: StoryLine.apps,
                  onChanged: (v) => setState(() => _targetApp = v!),
                ),
              ],
            ),
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

  Widget _filePicker(BuildContext context) {
    return Row(
      children: [
        SvgThumbnail(
          bytes: _bytes,
          fileName: _fileName,
          url: widget.existing?.imageUrl,
          size: 72,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OutlinedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.upload_file, size: 18),
                label: Text(_isEditing ? 'Replace image' : 'Choose image file'),
              ),
              const SizedBox(height: 6),
              Text(
                _fileName ??
                    (_isEditing ? 'Current image kept' : 'No file selected'),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
