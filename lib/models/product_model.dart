import 'package:flutter/foundation.dart';

enum ProductUnit {
  kg,
  grams,
  pieces,
}

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final List<String> imageUrls;
  final String categoryId;
  final bool inStock;
  final int stockQuantity;
  final double rating;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  // New fields for unit specification
  final ProductUnit unit;
  final double unitValue;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.imageUrls,
    required this.categoryId,
    this.inStock = true,
    this.stockQuantity = 0,
    this.rating = 0.0,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.unit = ProductUnit.pieces,
    this.unitValue = 1,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      discountPrice: (map['discountPrice'] as num?)?.toDouble(),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      categoryId: map['categoryId']?.toString() ?? '',
      inStock: map['inStock'] ?? true,
      stockQuantity: map['stockQuantity']?.toInt() ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'].toString())
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'].toString())
          : DateTime.now(),
      // Parse unit information
      unit: map['unit'] != null
          ? ProductUnit.values.firstWhere((e) => describeEnum(e) == map['unit'],
              orElse: () => ProductUnit.pieces)
          : ProductUnit.pieces,
      unitValue: (map['unitValue'] as num?)?.toDouble() ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'imageUrls': imageUrls,
      'categoryId': categoryId,
      'inStock': inStock,
      'stockQuantity': stockQuantity,
      'rating': rating,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      // Add unit information to map
      'unit': describeEnum(unit),
      'unitValue': unitValue,
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    List<String>? imageUrls,
    String? categoryId,
    bool? inStock,
    int? stockQuantity,
    double? rating,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProductUnit? unit,
    double? unitValue,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      imageUrls: imageUrls ?? this.imageUrls,
      categoryId: categoryId ?? this.categoryId,
      inStock: inStock ?? this.inStock,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      rating: rating ?? this.rating,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      unit: unit ?? this.unit,
      unitValue: unitValue ?? this.unitValue,
    );
  }

  // Helper method to get formatted unit string
  String get formattedUnit {
    switch (unit) {
      case ProductUnit.kg:
        return '${unitValue.toInt()} kg';
      case ProductUnit.grams:
        return '${unitValue.toInt()} g';
      case ProductUnit.pieces:
        return '${unitValue.toInt()} pc';
    }
  }
}
