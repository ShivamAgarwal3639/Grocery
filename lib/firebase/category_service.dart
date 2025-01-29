import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  final CollectionReference _categoriesCollection =
  FirebaseFirestore.instance.collection('categories');

  // Create a new category
  Future<String> createCategory(CategoryModel category) async {
    try {
      final docRef = await _categoriesCollection.add(category.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  // Read a single category
  Future<CategoryModel?> getCategory(String id) async {
    try {
      final doc = await _categoriesCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return CategoryModel.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get category: $e');
    }
  }

  // Read all active categories
  Stream<List<CategoryModel>> getAllCategories({
    bool activeOnly = true,
    String? searchQuery,
  }) {
    Query query = _categoriesCollection;

    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.where('searchKeywords', arrayContains: searchQuery.toLowerCase());
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => CategoryModel.fromMap({
      ...doc.data() as Map<String, dynamic>,
      'id': doc.id,
    }))
        .toList());
  }

  // Batch create categories
  Future<void> batchCreateCategories(List<CategoryModel> categories) async {
    final batch = FirebaseFirestore.instance.batch();

    for (var category in categories) {
      final docRef = _categoriesCollection.doc();
      batch.set(docRef, category.toMap());
    }

    await batch.commit();
  }

  // Update a category
  Future<void> updateCategory(String id, CategoryModel category) async {
    try {
      await _categoriesCollection.doc(id).update(category.toMap());
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  // Delete a category
  Future<void> deleteCategory(String id) async {
    try {
      await _categoriesCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  // Toggle category active status
  Future<void> toggleCategoryStatus(String id, bool isActive) async {
    try {
      await _categoriesCollection.doc(id).update({'isActive': isActive});
    } catch (e) {
      throw Exception('Failed to toggle category status: $e');
    }
  }
}