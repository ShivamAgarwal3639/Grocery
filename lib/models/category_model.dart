class CategoryModel {
  final String id;
  final String name;
  final String imageUrl;
  final String thumbnailUrl;
  final String description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.thumbnailUrl = '',
    required this.description,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      thumbnailUrl: map['thumbnailUrl']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? thumbnailUrl,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'CategoryModel('
        'id: $id, '
        'name: $name, '
        'imageUrl: $imageUrl, '
        'thumbnailUrl: $thumbnailUrl, '
        'description: $description, '
        'isActive: $isActive, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt)';
  }
}