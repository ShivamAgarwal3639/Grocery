import 'package:Super96Store/models/product_model.dart';

enum OrderStatus { pending, confirmed, processing, shipped, delivered, cancelled }

class CartItemModel {
  final String id;
  final ProductModel product;
  int quantity;
  final double price;

  CartItemModel({
    required this.id,
    required this.product,
    this.quantity = 1,
    required this.price,
  });

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id']?.toString() ?? '',
      product: ProductModel.fromMap(map['product'] ?? {}),
      quantity: map['quantity']?.toInt() ?? 1,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product': product.toMap(),
      'quantity': quantity,
      'price': price,
    };
  }

  double get total => price * quantity;
}

class CartModel {
  final String id;
  final String userId;
  final List<CartItemModel> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartModel({
    required this.id,
    required this.userId,
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      id: map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      items: List<CartItemModel>.from(
        (map['items'] ?? []).map((x) => CartItemModel.fromMap(x)),
      ),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'].toString())
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((x) => x.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  double get subtotal =>
      items.fold(0, (sum, item) => sum + item.total);

  double get tax => subtotal * 0.13;

  double get total => subtotal + tax;
}