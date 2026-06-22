/// A single SVG image managed by the portal.
class SvgAsset {
  final String id;
  final String name;
  final String description;
  final String category; // Drawing, Painting, Puzzle
  final String targetApp; // AR Drawing, Painting, Puzzle
  final String filePath; // path inside the storage bucket
  final String publicUrl;
  final bool isActive;
  final DateTime createdAt;

  const SvgAsset({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.targetApp,
    required this.filePath,
    required this.publicUrl,
    required this.isActive,
    required this.createdAt,
  });

  static const categories = ['Drawing', 'Painting', 'Puzzle'];
  static const apps = ['AR Drawing', 'Painting', 'Puzzle'];

  factory SvgAsset.fromMap(Map<String, dynamic> map) {
    return SvgAsset(
      id: map['id']?.toString() ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'Drawing',
      targetApp: map['target_app'] as String? ?? 'AR Drawing',
      filePath: map['file_path'] as String? ?? '',
      publicUrl: map['public_url'] as String? ?? '',
      isActive: map['is_active'] as bool? ?? true,
      createdAt:
          DateTime.tryParse(map['created_at']?.toString() ?? '') ??
              DateTime.now(),
    );
  }

  Map<String, dynamic> toInsert() => {
        'name': name,
        'description': description,
        'category': category,
        'target_app': targetApp,
        'file_path': filePath,
        'public_url': publicUrl,
        'is_active': isActive,
      };

  SvgAsset copyWith({
    String? name,
    String? description,
    String? category,
    String? targetApp,
    String? filePath,
    String? publicUrl,
    bool? isActive,
  }) {
    return SvgAsset(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      targetApp: targetApp ?? this.targetApp,
      filePath: filePath ?? this.filePath,
      publicUrl: publicUrl ?? this.publicUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}
