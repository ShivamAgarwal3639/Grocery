import 'package:Super96Store/screens/image_viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Super96Store/notifier/cart_notifier.dart';
import 'package:Super96Store/screens/main_pages/cart_page.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Super96Store/models/product_model.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: CircleAvatar(
            backgroundColor: Colors.grey.withOpacity(0.1),
            child: Icon(Icons.arrow_back, color: Colors.black),
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          Consumer<CartNotifier>(
            builder: (context, cartNotifier, _) {
              final itemCount = cartNotifier.cart.items.length;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined,
                        color: Colors.black),
                    onPressed: () => Get.to(() => CartPage()),
                  ),
                  if (itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green[700],
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$itemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // IconButton(
          //   icon: const Icon(Icons.favorite_border, color: Colors.black),
          //   onPressed: () {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(
          //         content: Text('Added to favorites'),
          //         behavior: SnackBarBehavior.floating,
          //       ),
          //     );
          //   },
          // ),
          // IconButton(
          //   icon: const Icon(Icons.share, color: Colors.black),
          //   onPressed: () {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(
          //         content: Text('Share feature coming soon'),
          //         behavior: SnackBarBehavior.floating,
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainImage(),
                  _buildImageCarousel(),
                  _buildProductInfo(context),
                  const Divider(height: 24),
                  _buildDescription(),
                  const SizedBox(
                      height: 80), // Extra space at bottom for scrolling
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildDynamicBottomBar(context),
    );
  }

  Widget _buildMainImage() {
    return Stack(
      children: [
        Container(
          height: 350,
          width: double.infinity,
          child: Hero(
            tag: 'product-${widget.product.id}',
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.product.imageUrls.length,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Get.to(() => ImageViewerPage(
                        imageUrls: widget.product.imageUrls,
                        initialIndex: _currentImageIndex));
                  },
                  child: CachedNetworkImage(
                    imageUrl: widget.product.imageUrls[index],
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child:  Center(
                        child: SizedBox(
                          child: Image.asset('assets/default_image_product.png',  fit: BoxFit.contain,),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: Icon(Icons.error_outline,
                          color: Colors.grey[400]),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // Discount badge
        if (widget.product.discountPrice != null)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${(((widget.product.price - (widget.product.discountPrice ?? 0)) / widget.product.price) * 100).toInt()}% OFF',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        // Dot indicators
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.product.imageUrls.asMap().entries.map((entry) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentImageIndex == entry.key
                      ? Colors.green
                      : Colors.grey.withOpacity(0.5),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildImageCarousel() {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.product.imageUrls.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _currentImageIndex == index
                      ? Colors.green
                      : Colors.grey[300]!,
                  width: _currentImageIndex == index ? 2 : 1,
                ),
                boxShadow: _currentImageIndex == index
                    ? [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 2,
                        )
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: widget.product.imageUrls[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child:  Center(
                      child: SizedBox(
                        child: Image.asset('assets/default_image_product.png',  fit: BoxFit.cover,),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.error_outline,
                        color: Colors.grey[400]),
                  ),
                ),
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
          // Product name and price
          Text(
            widget.product.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),

          // Price information
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '₹${(widget.product.discountPrice ?? widget.product.price).toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 12),
              if (widget.product.discountPrice != null)
                Text(
                  '₹${widget.product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Stock and unit information
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.product.inStock
                      ? Colors.green[50]
                      : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: widget.product.inStock ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.product.inStock ? 'In Stock' : 'Out of Stock',
                  style: TextStyle(
                    color: widget.product.inStock
                        ? Colors.green[700]
                        : Colors.red[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey[400]!,
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.product.formattedUnit,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(Icons.description_outlined, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Container(
          //   padding: const EdgeInsets.all(16),
          //   decoration: BoxDecoration(
          //     color: Colors.grey[50],
          //     borderRadius: BorderRadius.circular(12),
          //     border: Border.all(color: Colors.grey[200]!),
          //   ),
          //   child:
          Text(
            widget.product.description,
            style: TextStyle(
              color: Colors.grey[800],
              height: 1.5,
              fontSize: 15,
            ),
          ),
          // ),
        ],
      ),
    );
  }

  Widget _buildDynamicBottomBar(BuildContext context) {
    return Consumer<CartNotifier>(
      builder: (context, cartNotifier, child) {
        final cartItem = cartNotifier.cart.items
            .where((item) => item.product.id == widget.product.id)
            .firstOrNull;

        final isInCart = cartItem != null;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      onPressed: () => Get.to(() => CartPage()),
                      icon: Stack(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(5.0),
                            child: Icon(
                              Icons.shopping_cart_outlined,
                              size: 20,
                              color: Colors.green,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.green[700],
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
                      label: const Text(
                        'View Cart',
                        style: TextStyle(color: Colors.green),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: Colors.green[700]!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green[700],
                        borderRadius: BorderRadius.circular(12),
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
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.product.inStock
                          ? () {
                              cartNotifier.addToCart(widget.product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${widget.product.name} added to cart',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.green[700],
                                  behavior: SnackBarBehavior.floating,
                                  action: SnackBarAction(
                                    label: 'VIEW',
                                    textColor: Colors.white,
                                    onPressed: () => Get.to(() => CartPage()),
                                  ),
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
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
