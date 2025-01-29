import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_model.dart';

class CartService {
  final CollectionReference _cartsCollection =
  FirebaseFirestore.instance.collection('carts');

  // Create a new cart
  Future<String> createCart(CartModel cart) async {
    try {
      final docRef = await _cartsCollection.add(cart.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create cart: $e');
    }
  }

  // Get user's cart
  Future<CartModel?> getUserCart(String userId) async {
    try {
      final querySnapshot = await _cartsCollection
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return CartModel.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user cart: $e');
    }
  }

  // Add item to cart
  Future<void> addItemToCart(String cartId, CartItemModel item) async {
    try {
      final cart = await _cartsCollection.doc(cartId).get();
      if (cart.exists) {
        final cartData = cart.data() as Map<String, dynamic>;
        final items = List<CartItemModel>.from(
          (cartData['items'] ?? []).map((x) => CartItemModel.fromMap(x)),
        );

        // Check if item already exists
        final existingItemIndex = items.indexWhere((i) => i.product.id == item.product.id);
        if (existingItemIndex != -1) {
          items[existingItemIndex].quantity += item.quantity;
        } else {
          items.add(item);
        }

        await _cartsCollection.doc(cartId).update({
          'items': items.map((x) => x.toMap()).toList(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw Exception('Failed to add item to cart: $e');
    }
  }

  // Remove item from cart
  Future<void> removeItemFromCart(String cartId, String itemId) async {
    try {
      final cart = await _cartsCollection.doc(cartId).get();
      if (cart.exists) {
        final cartData = cart.data() as Map<String, dynamic>;
        final items = List<CartItemModel>.from(
          (cartData['items'] ?? []).map((x) => CartItemModel.fromMap(x)),
        ).where((item) => item.id != itemId).toList();

        await _cartsCollection.doc(cartId).update({
          'items': items.map((x) => x.toMap()).toList(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  // Clear cart
  Future<void> clearCart(String cartId) async {
    try {
      await _cartsCollection.doc(cartId).update({
        'items': [],
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }
}