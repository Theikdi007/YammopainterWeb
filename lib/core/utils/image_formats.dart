// Helpers for the asset uploader so it accepts any common photo/image format
// instead of being locked to SVG.

/// Image/photo extensions the uploader accepts (lower-case, no leading dot).
const List<String> kAllowedImageExtensions = [
  'svg',
  'png',
  'jpg',
  'jpeg',
  'gif',
  'webp',
  'bmp',
  'heic',
  'heif',
  'avif',
];

/// Maps a file name (or URL) to its MIME content type, used when uploading to
/// storage. Falls back to a generic binary type for unknown extensions.
String contentTypeForFile(String fileName) {
  switch (extensionOf(fileName)) {
    case 'svg':
      return 'image/svg+xml';
    case 'png':
      return 'image/png';
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'gif':
      return 'image/gif';
    case 'webp':
      return 'image/webp';
    case 'bmp':
      return 'image/bmp';
    case 'heic':
      return 'image/heic';
    case 'heif':
      return 'image/heif';
    case 'avif':
      return 'image/avif';
    default:
      return 'application/octet-stream';
  }
}

/// Whether [nameOrUrl] points to an SVG document, which needs a vector
/// renderer instead of the raster image renderer.
bool isSvgFile(String? nameOrUrl) =>
    nameOrUrl != null && extensionOf(nameOrUrl) == 'svg';

/// Lower-cased extension of a file name or URL, without the leading dot and
/// with any query string stripped. Returns an empty string when absent.
String extensionOf(String nameOrUrl) {
  final clean = nameOrUrl.split('?').first.split('#').first;
  final dot = clean.lastIndexOf('.');
  if (dot == -1 || dot == clean.length - 1) return '';
  return clean.substring(dot + 1).toLowerCase();
}
