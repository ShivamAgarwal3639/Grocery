import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Super96Store/models/cart_model.dart';
import '../models/order_model.dart';

class OrderService {
  final CollectionReference _ordersCollection =
  FirebaseFirestore.instance.collection('orders');

  // Create a new order
  Future<String> createOrder(OrderModel order) async {
    try {
      final docRef = await _ordersCollection.add(order.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // Get a single order
  Future<OrderModel?> getOrder(String id) async {
    try {
      final doc = await _ordersCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return OrderModel.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get order: $e');
    }
  }

  // Get user's orders
  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return OrderModel.fromMap(data);
      }).toList();
    });
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _ordersCollection.doc(orderId).update({
        'status': status.toString().split('.').last,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  // Update tracking number
  Future<void> updateTrackingNumber(String orderId, String trackingNumber) async {
    try {
      await _ordersCollection.doc(orderId).update({
        'trackingNumber': trackingNumber,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update tracking number: $e');
    }
  }

  // Get orders by status
  Stream<List<OrderModel>> getOrdersByStatus(OrderStatus status) {
    return _ordersCollection
        .where('status', isEqualTo: status.toString().split('.').last)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return OrderModel.fromMap(data);
      }).toList();
    });
  }
}