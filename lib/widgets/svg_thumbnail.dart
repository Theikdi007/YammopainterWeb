import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/utils/image_formats.dart';
import '../theme/app_colors.dart';

/// Renders an image preview either from raw bytes (before upload) or a network
/// URL (from storage). SVG files use a vector renderer; every other photo
/// format uses the raster image renderer. Falls back to a placeholder icon.
class SvgThumbnail extends StatelessWidget {
  const SvgThumbnail({
    super.key,
    this.bytes,
    this.url,
    this.fileName,
    this.size = 56,
  });

  final Uint8List? bytes;
  final String? url;

  /// File name of the picked file, used to choose the right renderer for the
  /// [bytes] preview before the file has been uploaded.
  final String? fileName;
  final double size;

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (bytes != null) {
      content = isSvgFile(fileName)
          ? SvgPicture.memory(bytes!, fit: BoxFit.contain)
          : Image.memory(
              bytes!,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => _placeholder(),
            );
    } else if (url != null && url!.isNotEmpty) {
      content = isSvgFile(url)
          ? SvgPicture.network(
              url!,
              fit: BoxFit.contain,
              placeholderBuilder: (_) => _placeholder(),
            )
          : Image.network(
              url!,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => _placeholder(),
            );
    } else {
      content = _placeholder();
    }

    return Container(
      height: size,
      width: size,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: content,
    );
  }

  Widget _placeholder() => const Icon(
        Icons.image_outlined,
        color: AppColors.primary,
      );
}
