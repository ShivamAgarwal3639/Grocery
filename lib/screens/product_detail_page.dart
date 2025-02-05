import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grocerry/notifier/cart_notifier.dart';
import 'package:grocerry/screens/main_pages/cart_page.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:grocerry/models/product_model.dart';

class ProductDetailPage extends StatelessWidget {
  final ProductModel product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageCarousel(),
                _buildProductInfo(context),
                _buildDescription(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildDynamicBottomBar(context),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'product-${product.id}',
          child: CachedNetworkImage(
            imageUrl: product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
      leading: IconButton(
        icon: const CircleAvatar(
          backgroundColor: Colors.white,
          child: Icon(Icons.arrow_back, color: Colors.black),
        ),
        onPressed: () => Get.back(),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        itemCount: 1,
        itemBuilder: (context, index) {
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: product.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              if (product.discountPrice != null) ...[
                Text(
                  '₹${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                '₹${(product.discountPrice ?? product.price).toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              // Icon(Icons.star, color: Colors.amber[700], size: 20),
              // const SizedBox(width: 4),
              // Text(
              //   product.rating.toStringAsFixed(1),
              //   style: const TextStyle(fontWeight: FontWeight.bold),
              // ),
              // const SizedBox(width: 16),
              if (product.inStock)
                const Text(
                  'In Stock',
                  style: TextStyle(color: Colors.green),
                )
              else
                const Text(
                  'Out of Stock',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.description,
            style: TextStyle(
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicBottomBar(BuildContext context) {
    return Consumer<CartNotifier>(
      builder: (context, cartNotifier, child) {
        // Fixed the null handling here
        final cartItem = cartNotifier.cart.items
            .where((item) => item.product.id == product.id)
            .firstOrNull;

        final isInCart = cartItem != null;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                if (isInCart && cartItem != null) ...[
                  // View Cart Button
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      onPressed: () => Get.to(() => CartPage()),
                      icon: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: const Icon(
                              Icons.shopping_cart_outlined,
                              size: 20,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.pink,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${cartNotifier.cart.items.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      label: const Text('View Cart'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 9, horizontal: 0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Colors.pink),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Quantity Controls
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.pink,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, color: Colors.white),
                            onPressed: () => cartNotifier.updateQuantity(
                              cartItem.id,
                              cartItem.quantity - 1,
                            ),
                          ),
                          Text(
                            '${cartItem.quantity}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.white),
                            onPressed: () => cartNotifier.updateQuantity(
                              cartItem.id,
                              cartItem.quantity + 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else
                  // Add to Cart Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: product.inStock
                          ? () {
                              cartNotifier.addToCart(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('${product.name} added to cart'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
