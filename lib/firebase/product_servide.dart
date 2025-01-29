import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final CollectionReference _productsCollection =
      FirebaseFirestore.instance.collection('products');

  // Create a new product
  Future<String> createProduct(ProductModel product) async {
    try {
      final docRef = await _productsCollection.add(product.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  // Read a single product
  Future<ProductModel?> getProduct(String id) async {
    try {
      final doc = await _productsCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ProductModel.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get product: $e');
    }
  }

  Stream<List<ProductModel>> getAllProducts({
    String? categoryId,
    String sortBy = 'name',
    bool descending = false,
  }) {
    Query query = _productsCollection;
    log("-------------$categoryId");

    if (categoryId != null) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }

    return query
        // .orderBy(sortBy, descending: descending)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap({
                  ...doc.data() as Map<String, dynamic>,
                  'id': doc.id,
                }))
            .toList());
  }

  // Batch create products
  Future<void> batchCreateProducts(List<ProductModel> products) async {
    final batch = FirebaseFirestore.instance.batch();

    for (var product in products) {
      final docRef = _productsCollection.doc();
      batch.set(docRef, product.toMap());
    }

    await batch.commit();
  }

  // Update product stock
  Future<void> updateStock(String id, int quantity) async {
    try {
      await _productsCollection.doc(id).update({'stock': quantity});
    } catch (e) {
      throw Exception('Failed to update stock: $e');
    }
  }

  // Update a product
  Future<void> updateProduct(String id, ProductModel product) async {
    try {
      await _productsCollection.doc(id).update(product.toMap());
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  // Delete a product
  Future<void> deleteProduct(String id) async {
    try {
      await _productsCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // Get products by category
  Stream<List<ProductModel>> getProductsByCategory(String categoryId) {
    return _productsCollection
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ProductModel.fromMap(data);
      }).toList();
    });
  }
}
