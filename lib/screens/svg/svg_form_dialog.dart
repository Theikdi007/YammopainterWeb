import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/story_line_controller.dart';
import '../../controllers/svg_controller.dart';
import '../../core/utils/image_formats.dart';
import '../../core/utils/ui_helpers.dart';
import '../../models/svg_asset.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/svg_thumbnail.dart';

class SvgFormDialog extends StatefulWidget {
  const SvgFormDialog({super.key, this.existing});

  final SvgAsset? existing;

  @override
  State<SvgFormDialog> createState() => _SvgFormDialogState();
}

class _SvgFormDialogState extends State<SvgFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  late String _category;
  late String _targetApp;

  Uint8List? _bytes;
  String? _fileName;
  String? _storyLineId;
  bool _saving = false;

  final SvgController _controller = Get.find<SvgController>();
  final StoryLineController _storyLineController = Get.find<StoryLineController>();

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name.text = e?.name ?? '';
    _description.text = e?.description ?? '';
    _category = e?.category ?? SvgAsset.categories.first;
    _targetApp = e?.targetApp ?? SvgAsset.apps.first;
    _storyLineId = e?.storyLineId;
  }

  @override
  void dispose() {
    _name.dispose();
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
          name: _name.text.trim(),
          description: _description.text.trim(),
          category: _category,
          targetApp: _targetApp,
          storyLineId: _storyLineId,
        ),
        bytes: _bytes,
        fileName: _fileName,
      );
    } else {
      ok = await _controller.create(
        name: _name.text.trim(),
        description: _description.text.trim(),
        category: _category,
        targetApp: _targetApp,
        bytes: _bytes!,
        fileName: _fileName!,
        storyLineId: _storyLineId,
      );
    }
    if (mounted) setState(() => _saving = false);
    if (ok) {
      Get.back<void>();
      await showSuccessDialog(
        _isEditing
            ? 'Image updated successfully.'
            : 'Image uploaded successfully.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Edit Image' : 'Upload new image'),
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
                _storiesDropdown(context),
                const SizedBox(height: 14),
                _dropdown(
                  label: 'Category',
                  value: _category,
                  items: SvgAsset.categories,
                  onChanged: (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: 14),
                _dropdown(
                  label: 'Target app',
                  value: _targetApp,
                  items: SvgAsset.apps,
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
              : Text(_isEditing ? 'Save' : 'Upload'),
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
          url: widget.existing?.publicUrl,
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

  Widget _storiesDropdown(BuildContext context) {
    return Obx(() {
      final stories = _storyLineController.items.where((s) => s.isActive).toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Story',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: stories.any((s) => s.id == _storyLineId) ? _storyLineId : null,
            isExpanded: true,
            hint: const Text('None'),
            items: [
              const DropdownMenuItem(value: null, child: Text('None')),
              ...stories.map((s) => DropdownMenuItem(
                  value: s.id, child: Text(s.title, overflow: TextOverflow.ellipsis))),
            ],
            onChanged: (v) => setState(() => _storyLineId = v),
          ),
        ],
      );
    });
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
