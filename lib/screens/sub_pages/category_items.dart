import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grocerry/firebase/product_servide.dart';
import 'package:grocerry/models/category_model.dart';
import 'package:grocerry/models/product_model.dart';
import 'package:grocerry/notifier/cart_notifier.dart';
import 'package:grocerry/screens/product_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class CategoryItemsPage extends StatefulWidget {
  const CategoryItemsPage({super.key, required this.categoryId});
  final CategoryModel categoryId;

  @override
  State<CategoryItemsPage> createState() => _CategoryItemsPageState();
}

class _CategoryItemsPageState extends State<CategoryItemsPage> {
  final ProductService _productService = ProductService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final _searchSubject = BehaviorSubject<String>();
  List<ProductModel> _filteredProducts = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _setupSearch();
  }

  void _setupSearch() {
    _searchSubject.stream
        .debounceTime(const Duration(milliseconds: 300))
        .distinct()
        .listen((query) {
      setState(() => _isSearching = query.isNotEmpty);
    });

    _searchController.addListener(() {
      _searchSubject.add(_searchController.text);
    });
  }

  List<ProductModel> _filterProducts(List<ProductModel> products, String query) {
    if (query.isEmpty) return products;

    final searchLower = query.toLowerCase();
    return products.where((product) {
      return product.name.toLowerCase().contains(searchLower) ||
          product.description.toLowerCase().contains(searchLower) ||
          product.tags.any((tag) => tag.toLowerCase().contains(searchLower));
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchSubject.close();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<ProductModel>>(
        stream: _productService.getAllProducts(
          categoryId: widget.categoryId.id,
          sortBy: 'name',
        ),
        builder: (context, productsSnapshot) {
          if (productsSnapshot.hasError) {
            return _buildErrorState('Error: ${productsSnapshot.error}');
          }

          if (!productsSnapshot.hasData) {
            return _buildLoadingState();
          }

          _filteredProducts = _filterProducts(
            productsSnapshot.data!,
            _searchController.text,
          );

          return Consumer<CartNotifier>(
            builder: (context, cart, child) {
              return NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  _buildAppBar(innerBoxIsScrolled),
                ],
                body: _filteredProducts.isEmpty && _isSearching
                    ? _buildNoResultsFound()
                    : _buildProductGrid(_filteredProducts, cart),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNoResultsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try different keywords',
            style: TextStyle(
              color: Colors.grey[500],
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
      title: _isSearching
          ? TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search in ${widget.categoryId.name}...',
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 16),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(Icons.clear, color: Colors.grey[600]),
            onPressed: () {
              _searchController.clear();
              setState(() => _isSearching = false);
            },
          ),
        ),
      )
          : Row(
        children: [
          Expanded(
            child: Text(
              widget.categoryId.name,
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            color: Colors.grey[800],
            onPressed: () => setState(() => _isSearching = true),
          ),
        ],
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
            childAspectRatio: 0.80,
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
                        imageUrl: product.imageUrl,
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
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                  ),
                                ),
                              Text(
                                '\$${(product.discountPrice ?? product.price).toStringAsFixed(2)}',
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
        height: 32,
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 28,
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
              width: 24,
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
              width: 28,
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
      height: 32,
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
