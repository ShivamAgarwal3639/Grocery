import 'package:Super96Store/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:Super96Store/screens/main_pages/cart_page.dart';
import 'package:Super96Store/screens/main_pages/categories_page.dart';
import 'package:Super96Store/screens/main_pages/product_screen.dart';
import 'package:get/get.dart';
import 'package:Super96Store/notifier/cart_notifier.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const ProductsPage(),
    const CategoriesPage(),
    const CartPage(),
  ];

  @override
  void initState() {
    super.initState();
    Utility.initialize(context);

    // Check if we got an index from arguments
    if (Get.arguments != null && Get.arguments is int) {
      _selectedIndex = Get.arguments;
    }

    // Load cart data when the HomeScreen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartNotifier>(context, listen: false).loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: Consumer<CartNotifier>(
        builder: (context, cartNotifier, child) {
          final totalQuantity = cartNotifier.cart.items
              .fold<int>(0, (sum, item) => sum + item.quantity);

          return NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: Theme.of(context).primaryColor.withOpacity(0.1),
              labelTextStyle: MaterialStateProperty.all(
                TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
            child: NavigationBar(
              elevation: 0,
              height: 65,
              backgroundColor: Colors.white,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.store_outlined),
                  selectedIcon: Icon(Icons.store),
                  label: 'Products',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.category_outlined),
                  selectedIcon: Icon(Icons.category),
                  label: 'Categories',
                ),
                NavigationDestination(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.shopping_cart_outlined),
                      if (totalQuantity > 0)
                        Positioned(
                          right: -8,
                          top: -8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Center(
                              child: Text(
                                '$totalQuantity',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  selectedIcon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.shopping_cart),
                      if (totalQuantity > 0)
                        Positioned(
                          right: -8,
                          top: -8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Center(
                              child: Text(
                                '$totalQuantity',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: 'Cart',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
