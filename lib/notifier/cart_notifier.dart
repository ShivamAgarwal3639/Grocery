// cart_notifier.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:Super96Store/models/cart_model.dart';
import 'package:Super96Store/models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartNotifier extends ChangeNotifier {
  static const String _cartKey = 'cart_data';
  CartModel? _cart;

  CartModel get cart => _cart ?? CartModel(
    id: DateTime.now().toString(),
    userId: 'local_user',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  Future<void> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getString(_cartKey);
    if (cartData != null) {
      _cart = CartModel.fromMap(json.decode(cartData));
      notifyListeners();
    }
  }

  Future<void> saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cartKey, json.encode(cart.toMap()));
  }

  Future<void> addToCart(ProductModel product, {int quantity = 1}) async {
    final existingItemIndex = cart.items.indexWhere(
            (item) => item.product.id == product.id
    );

    if (existingItemIndex >= 0) {
      final updatedItems = List<CartItemModel>.from(cart.items);
      updatedItems[existingItemIndex].quantity += quantity;
      _cart = CartModel(
        id: cart.id,
        userId: cart.userId,
        items: updatedItems,
        createdAt: cart.createdAt,
        updatedAt: DateTime.now(),
      );
    } else {
      final newItem = CartItemModel(
        id: DateTime.now().toString(),
        product: product,
        quantity: quantity,
        price: product.discountPrice ?? product.price,
      );
      _cart = CartModel(
        id: cart.id,
        userId: cart.userId,
        items: [...cart.items, newItem],
        createdAt: cart.createdAt,
        updatedAt: DateTime.now(),
      );
    }

    await saveCart();
    notifyListeners();
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    final updatedItems = List<CartItemModel>.from(cart.items);
    final itemIndex = updatedItems.indexWhere((item) => item.id == itemId);

    if (itemIndex >= 0) {
      if (quantity <= 0) {
        updatedItems.removeAt(itemIndex);
      } else {
        updatedItems[itemIndex].quantity = quantity;
      }

      _cart = CartModel(
        id: cart.id,
        userId: cart.userId,
        items: updatedItems,
        createdAt: cart.createdAt,
        updatedAt: DateTime.now(),
      );

      await saveCart();
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String itemId) async {
    _cart = CartModel(
      id: cart.id,
      userId: cart.userId,
      items: cart.items.where((item) => item.id != itemId).toList(),
      createdAt: cart.createdAt,
      updatedAt: DateTime.now(),
    );

    await saveCart();
    notifyListeners();
  }

  Future<void> clearCart() async {
    _cart = CartModel(
      id: DateTime.now().toString(),
      userId: cart.userId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await saveCart();
    notifyListeners();
  }
}