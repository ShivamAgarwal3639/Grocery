import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Super96Store/firebase/category_service.dart';
import 'package:Super96Store/firebase/product_servide.dart';
import 'package:Super96Store/firebase/promotion_service.dart';
import 'package:Super96Store/models/category_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:Super96Store/models/product_model.dart';
import 'package:Super96Store/models/promotion_model.dart';
import 'package:Super96Store/notifier/cart_notifier.dart';
import 'package:Super96Store/screens/product_detail_page.dart';
import 'package:Super96Store/screens/profile/profile_page.dart';
import 'package:Super96Store/screens/sub_pages/search_product.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  String? _selectedCategoryId;
  int _currentCarouselIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final PromotionService _promotionService = PromotionService();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<CategoryModel>>(
        stream: _categoryService.getAllCategories(),
        builder: (context, categoriesSnapshot) {
          if (categoriesSnapshot.hasError) {
            return _buildErrorState('Error: ${categoriesSnapshot.error}');
          }

          return StreamBuilder<List<ProductModel>>(
            stream: _productService.getAllProducts(
              categoryId: _selectedCategoryId,
              sortBy: 'name',
            ),
            builder: (context, productsSnapshot) {
              if (productsSnapshot.hasError) {
                return _buildErrorState('Error: ${productsSnapshot.error}');
              }

              if (!productsSnapshot.hasData || !categoriesSnapshot.hasData) {
                return _buildLoadingState();
              }

              return Consumer<CartNotifier>(
                builder: (context, cart, child) {
                  return NestedScrollView(
                    controller: _scrollController,
                    headerSliverBuilder: (context, innerBoxIsScrolled) => [
                      _buildAppBar(innerBoxIsScrolled),
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            _buildSearchBar(),
                            const SizedBox(
                              height: 4,
                            ),
                            _buildPromotionCarousel(),
                            _buildCategoryFilter(categoriesSnapshot.data!),
                          ],
                        ),
                      ),
                    ],
                    body: _buildProductGrid(productsSnapshot.data!, cart),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => setState(() {}),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading products...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(bool innerBoxIsScrolled) {
    return SliverAppBar(
      floating: true,
      pinned: true,
      elevation: innerBoxIsScrolled ? 4 : 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Row(
        children: [
          Icon(Icons.shopping_basket_outlined,
              size: 30, color: Colors.green[700]),
          const SizedBox(width: 8),
          Text(
            'GroCart',
            style: TextStyle(
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.account_circle_outlined,
              color: Colors.grey[800],
            ),
            onPressed: () => Get.to(() => ProfilePage()),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () => Get.to(() => SearchPage()),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey[600]),
                    const SizedBox(width: 12),
                    Text(
                      'Search products...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPromotionCarousel() {
    return StreamBuilder<List<PromotionModel>>(
      stream: _promotionService.getActivePromotions(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error loading promotions: ${snapshot.error}',
                style: TextStyle(color: Colors.red[300]),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final promotions = snapshot.data!;

        if (promotions.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 180,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.9,
                autoPlayInterval: const Duration(seconds: 4),
                onPageChanged: (index, reason) {
                  setState(() => _currentCarouselIndex = index);
                },
              ),
              items: promotions.map((promotion) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      height: 180,
                      width: MediaQuery.of(context).size.width -
                          (MediaQuery.of(context).size.width / 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            promotion.getColor1(),
                            promotion.getColor2()
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -30,
                            bottom: -30,
                            child: CircleAvatar(
                              radius: 100,
                              backgroundColor: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            promotion.discount,
                                            style: TextStyle(
                                              color: promotion.getColor1(),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (promotion.isCoupon) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: const Text(
                                              'COUPON',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    if (promotion.title.isNotEmpty)
                                      Flexible(
                                        child: Text(
                                          promotion.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    if (promotion.subtitle.isNotEmpty)
                                      Flexible(
                                        child: Text(
                                          promotion.subtitle,
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.9),
                                            fontSize: 16,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    const Spacer(),
                                    if (promotion.isCoupon)
                                      Flexible(
                                        child: Text(
                                          promotion.discountType == 'PERCENTAGE'
                                              ? '${promotion.discountValue}% off on min. order of ₹${promotion.minOrderValue}${promotion.maxDiscountAmount > 0 ? ' | Max discount: ₹${promotion.maxDiscountAmount}' : ''}'
                                              : 'Flat ₹${promotion.discountValue} off on min. order of ₹${promotion.minOrderValue}',
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.9),
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Valid until ${DateFormat('MMM d, y').format(promotion.endDate)}',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: promotions.asMap().entries.map((entry) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentCarouselIndex == entry.key ? 20.0 : 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentCarouselIndex == entry.key
                        ? Colors.green
                        : Colors.green.withOpacity(0.3),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

// Helper method to format end date
  String _formatEndDate(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference < 7) {
      return 'in $difference days';
    } else {
      return DateFormat('MMM d').format(endDate);
    }
  }

  Widget _buildCategoryFilter(List<CategoryModel> categories) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCategoryChip(
              label: 'All',
              selected: _selectedCategoryId == null,
              onSelected: (selected) {
                if (selected) setState(() => _selectedCategoryId = null);
              },
            );
          }
          final category = categories[index - 1];
          return _buildCategoryChip(
            label: category.name,
            selected: _selectedCategoryId == category.id,
            onSelected: (selected) {
              if (selected) setState(() => _selectedCategoryId = category.id);
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: onSelected,
        backgroundColor: Colors.grey[100],
        selectedColor: Colors.green[100],
        checkmarkColor: Colors.green[700],
        labelStyle: TextStyle(
          color: selected ? Colors.green[700] : Colors.grey[700],
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selected ? Colors.green[200]! : Colors.grey[300]!,
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid(List<ProductModel> products, CartNotifier cart) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.75, // Adjusted for better content fit
          ),
          itemCount: products.length,
          itemBuilder: (context, index) =>
              _buildProductCard(products[index], cart),
        );
      },
    );
  }

  Widget _buildProductCard(ProductModel product, CartNotifier cart) {
    final inCart = cart.cart.items.any((item) => item.product.id == product.id);
    final cartItem = inCart
        ? cart.cart.items.firstWhere((item) => item.product.id == product.id)
        : null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Get.to(() => ProductDetailPage(product: product)),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 4,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'product-${product.id}',
                      child: CachedNetworkImage(
                        imageUrl: product.imageUrls.first,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.error_outline),
                        ),
                      ),
                    ),
                    if (product.discountPrice != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[500],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(((product.price - product.discountPrice!) / product.price) * 100).round()}% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),

                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 2),
                    Flexible(
                      child: Text(
                        product.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (product.discountPrice != null)
                                Text(
                                  '₹${product.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                  ),
                                ),
                              Text(
                                '₹${(product.discountPrice ?? product.price).toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        _buildCartButton(product, cart, cartItem, inCart),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartButton(
    ProductModel product,
    CartNotifier cart,
    dynamic cartItem,
    bool inCart,
  ) {
    if (inCart) {
      return Container(
        height: 32, // Fixed height for consistency
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 28, // Fixed width for the remove button
              height: 32,
              child: IconButton(
                icon: Icon(Icons.remove, size: 14, color: Colors.green[700]),
                onPressed: () => cart.updateQuantity(
                  cartItem.id,
                  cartItem.quantity - 1,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
            SizedBox(
              width: 24, // Fixed width for the quantity text
              child: Text(
                '${cartItem.quantity}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.green[700],
                ),
              ),
            ),
            SizedBox(
              width: 28, // Fixed width for the add button
              height: 32,
              child: IconButton(
                icon: Icon(Icons.add, size: 14, color: Colors.green[700]),
                onPressed: () => cart.updateQuantity(
                  cartItem.id,
                  cartItem.quantity + 1,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 32, // Fixed height to match the quantity selector
      child: ElevatedButton(
        onPressed: () {
          cart.addToCart(product);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} added to cart'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              action: SnackBarAction(
                label: 'UNDO',
                onPressed: () => cart.removeFromCart(product.id),
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        ),
        child: const Text(
          'Add',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
