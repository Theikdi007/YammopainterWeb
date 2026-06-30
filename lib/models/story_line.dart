class StoryLine {
  final String id;
  final String title;
  final String description;
  final String category;
  final String targetApp;
  final String imagePath;
  final String imageUrl;
  final bool isActive;
  final DateTime? date;
  final DateTime createdAt;

  const StoryLine({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.targetApp,
    required this.imagePath,
    required this.imageUrl,
    required this.isActive,
    this.date,
    required this.createdAt,
  });

  static const categories = ['Drawing', 'Painting', 'Puzzle'];
  static const apps = ['AR Drawing', 'Painting', 'Puzzle'];

  factory StoryLine.fromMap(Map<String, dynamic> map) {
    return StoryLine(
      id: map['id']?.toString() ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'Drawing',
      targetApp: map['target_app'] as String? ?? 'AR Drawing',
      imagePath: map['image_path'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? '',
      isActive: map['is_active'] as bool? ?? true,
      date: map['date'] != null
          ? DateTime.tryParse(map['date'].toString())
          : null,
      createdAt:
          DateTime.tryParse(map['created_at']?.toString() ?? '') ??
              DateTime.now(),
    );
  }

  Map<String, dynamic> toInsert() => {
        'title': title,
        'description': description,
        'category': category,
        'target_app': targetApp,
        'image_path': imagePath,
        'image_url': imageUrl,
        'is_active': isActive,
        if (date != null) 'date': date!.toIso8601String().split('T').first,
      };

  StoryLine copyWith({
    String? title,
    String? description,
    String? category,
    String? targetApp,
    String? imagePath,
    String? imageUrl,
    bool? isActive,
    DateTime? date,
  }) {
    return StoryLine(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      targetApp: targetApp ?? this.targetApp,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      date: date ?? this.date,
      createdAt: createdAt,
    );
  }
}
