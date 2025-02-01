import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocerry/models/promotion_model.dart';

class PromotionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'promotions';

  // Get all active promotions
  Stream<List<PromotionModel>> getActivePromotions() {
    return _firestore
        .collection(_collection)
        // .where('isActive', isEqualTo: true)
        .where('endDate', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .orderBy('endDate')
        .orderBy('displayOrder')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PromotionModel.fromFirestore(doc.data()))
            .toList());
  }

  // Add a new promotion
  Future<void> addPromotion(PromotionModel promotion) {
    return _firestore.collection(_collection).add(promotion.toFirestore());
  }

  // Update an existing promotion
  Future<void> updatePromotion(String id, PromotionModel promotion) {
    return _firestore
        .collection(_collection)
        .doc(id)
        .update(promotion.toFirestore());
  }

  // Delete a promotion
  Future<void> deletePromotion(String id) {
    return _firestore.collection(_collection).doc(id).delete();
  }

  // Get a single promotion by ID
  Stream<PromotionModel?> getPromotionById(String id) {
    return _firestore.collection(_collection).doc(id).snapshots().map(
        (doc) => doc.exists ? PromotionModel.fromFirestore(doc.data()!) : null);
  }

  // Get promotions by category
  Stream<List<PromotionModel>> getPromotionsByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('categories', arrayContains: category)
        .where('isActive', isEqualTo: true)
        .where('endDate', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .orderBy('endDate')
        .orderBy('displayOrder')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PromotionModel.fromFirestore(doc.data()))
            .toList());
  }

  // Toggle promotion active status
  Future<void> togglePromotionStatus(String id, bool isActive) {
    return _firestore
        .collection(_collection)
        .doc(id)
        .update({'isActive': isActive});
  }

  // Update promotion display order
  Future<void> updateDisplayOrder(String id, int newOrder) {
    return _firestore
        .collection(_collection)
        .doc(id)
        .update({'displayOrder': newOrder});
  }

  // Extend promotion end date
  Future<void> extendPromotionEndDate(String id, DateTime newEndDate) {
    return _firestore
        .collection(_collection)
        .doc(id)
        .update({'endDate': Timestamp.fromDate(newEndDate)});
  }
}
