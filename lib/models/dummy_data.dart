// lib/data/dummy_data.dart
import 'package:Super96Store/models/category_model.dart';
import 'package:Super96Store/models/product_model.dart';

class DummyData {
  // static List<CategoryModel> categories = [
  //   CategoryModel(
  //     id: 'cat-1',
  //     name: 'Fruits',
  //     imageUrl: 'https://placehold.jp/150x150.png',
  //     description: 'Fresh and seasonal fruits',
  //     isActive: true,
  //   ),
  //   CategoryModel(
  //     id: 'cat-2',
  //     name: 'Vegetables',
  //     imageUrl: 'https://placehold.jp/150x150.png',
  //     description: 'Organic vegetables',
  //     isActive: true,
  //   ),
  //   CategoryModel(
  //     id: 'cat-3',
  //     name: 'Dairy & Eggs',
  //     imageUrl: 'https://placehold.jp/150x150.png',
  //     description: 'Fresh dairy products and eggs',
  //     isActive: true,
  //   ),
  // ];
  //
  // static List<ProductModel> products = [
  //   ProductModel(
  //     id: '1',
  //     name: 'Fresh Apples',
  //     description: 'Sweet and juicy red apples',
  //     price: 2.99,
  //     imageUrl: 'https://placehold.jp/150x150.png',
  //     categoryId: 'cat-1',
  //     images: [
  //       'https://placehold.jp/150x150.png',
  //       'https://placehold.jp/150x150.png',
  //     ],
  //     inStock: true,
  //     stockQuantity: 100,
  //     rating: 4.5,
  //     tags: ['fresh', 'fruit', 'organic'],
  //     createdAt: DateTime.now(),
  //     updatedAt: DateTime.now(),
  //   ),
  //   ProductModel(
  //     id: '2',
  //     name: 'Organic Carrots',
  //     description: 'Fresh organic carrots',
  //     price: 1.99,
  //     discountPrice: 1.49,
  //     imageUrl: 'https://placehold.jp/150x150.png',
  //     categoryId: 'cat-2',
  //     images: [
  //       'https://placehold.jp/150x150.png',
  //       'https://placehold.jp/150x150.png',
  //     ],
  //     inStock: true,
  //     stockQuantity: 150,
  //     rating: 4.3,
  //     tags: ['vegetable', 'organic'],
  //     createdAt: DateTime.now(),
  //     updatedAt: DateTime.now(),
  //   ),
  //   ProductModel(
  //     id: '3',
  //     name: 'Free Range Eggs',
  //     description: 'Farm fresh eggs',
  //     price: 4.99,
  //     imageUrl: 'https://placehold.jp/150x150.png',
  //     categoryId: 'cat-3',
  //     images: [
  //       'https://placehold.jp/150x150.png',
  //       'https://placehold.jp/150x150.png',
  //     ],
  //     inStock: true,
  //     stockQuantity: 50,
  //     rating: 4.8,
  //     tags: ['eggs', 'dairy', 'organic'],
  //     createdAt: DateTime.now(),
  //     updatedAt: DateTime.now(),
  //   ),
  //   ProductModel(
  //     id: '4',
  //     name: 'Organic Bananas',
  //     description: 'Fresh organic bananas',
  //     price: 3.49,
  //     discountPrice: 2.99,
  //     imageUrl: 'https://placehold.jp/150x150.png',
  //     categoryId: 'cat-1',
  //     images: [
  //       'https://placehold.jp/150x150.png',
  //       'https://placehold.jp/150x150.png',
  //     ],
  //     inStock: true,
  //     stockQuantity: 75,
  //     rating: 4.6,
  //     tags: ['fruit', 'organic'],
  //     createdAt: DateTime.now(),
  //     updatedAt: DateTime.now(),
  //   ),
  //   ProductModel(
  //     id: '5',
  //     name: 'Fresh Spinach',
  //     description: 'Organic baby spinach leaves',
  //     price: 2.49,
  //     imageUrl: 'https://placehold.jp/150x150.png',
  //     categoryId: 'cat-2',
  //     images: [
  //       'https://placehold.jp/150x150.png',
  //       'https://placehold.jp/150x150.png',
  //     ],
  //     inStock: true,
  //     stockQuantity: 80,
  //     rating: 4.4,
  //     tags: ['vegetable', 'organic', 'leafy'],
  //     createdAt: DateTime.now(),
  //     updatedAt: DateTime.now(),
  //   ),
  // ];
  //
  // // Helper method to get products by category
  // static List<ProductModel> getProductsByCategory(String categoryId) {
  //   if (categoryId.isEmpty) return products;
  //   return products.where((product) => product.categoryId == categoryId).toList();
  // }
  //
  // // Helper method to get product by id
  // static ProductModel? getProductById(String id) {
  //   try {
  //     return products.firstWhere((product) => product.id == id);
  //   } catch (e) {
  //     return null;
  //   }
  // }
  //
  // // Helper method to get category by id
  // static CategoryModel? getCategoryById(String id) {
  //   try {
  //     return categories.firstWhere((category) => category.id == id);
  //   } catch (e) {
  //     return null;
  //   }
  // }
  //
  // // Helper method to get featured products (those with discounts)
  // static List<ProductModel> getFeaturedProducts() {
  //   return products.where((product) => product.discountPrice != null).toList();
  // }
  //
  // // Helper method to get top rated products
  // static List<ProductModel> getTopRatedProducts() {
  //   final sortedProducts = List<ProductModel>.from(products);
  //   sortedProducts.sort((a, b) => b.rating.compareTo(a.rating));
  //   return sortedProducts.take(3).toList();
  // }
}