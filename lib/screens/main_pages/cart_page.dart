import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grocerry/firebase/tax_delivery_service.dart';
import 'package:grocerry/models/cart_model.dart';
import 'package:grocerry/models/promotion_model.dart';
import 'package:grocerry/models/tax_delivery_model.dart';
import 'package:grocerry/notifier/cart_notifier.dart';
import 'package:grocerry/screens/checkout_page.dart';
import 'package:provider/provider.dart';
import 'package:grocerry/widgets/cart_button.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  PromotionModel? appliedPromotion;

  final TextEditingController _couponController = TextEditingController();

  bool isLoadingCoupon = false;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon(BuildContext context, CartModel cart) async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    setState(() => isLoadingCoupon = true);

    try {
      // Query Firestore for the promotion
      final promotionSnapshot = await FirebaseFirestore.instance
          .collection('promotions')
          .where('discount', isEqualTo: code)
          .where('isCoupon', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .where('endDate', isGreaterThan: Timestamp.fromDate(DateTime.now()))
          .get();

      if (promotionSnapshot.docs.isEmpty) {
        throw 'Invalid or expired coupon code';
      }

      final promotion = PromotionModel.fromFirestore(
        promotionSnapshot.docs.first.data(),
      );

      // Validate minimum order value
      if (cart.subtotal < promotion.minOrderValue) {
        throw 'Minimum order value of \$${promotion.minOrderValue.toStringAsFixed(2)} required';
      }

      setState(() => appliedPromotion = promotion);
      _couponController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Coupon applied successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => isLoadingCoupon = false);
    }
  }

  void _removeCoupon() {
    setState(() => appliedPromotion = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coupon removed'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  double _calculateDiscount(CartModel cart) {
    if (appliedPromotion == null) return 0.0;
    return appliedPromotion!.calculateDiscount(cart.subtotal);
  }

  Future<TaxAndDeliveryModel?> _loadTaxSettings(BuildContext context) async {
    final taxService = TaxAndDeliveryService();
    // You might want to store this ID in your app's configuration
    return await taxService.getTaxAndDelivery('default');
  }

  double calculateCharges(
    CartModel cart,
    TaxAndDeliveryModel settings,
  ) {
    final taxService = TaxAndDeliveryService();
    return taxService.calculateTotalCharges(
      cartValue: cart.subtotal,
      settings: settings,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartNotifier>(
      builder: (context, cartNotifier, child) {
        return FutureBuilder<TaxAndDeliveryModel?>(
          future: _loadTaxSettings(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final cart = cartNotifier.cart;
            final settings =
                snapshot.data ?? TaxAndDeliveryModel(id: 'default');
            final total = calculateCharges(cart, settings);

            return Scaffold(
              backgroundColor: Colors.grey[50],
              appBar: AppBar(
                title: Text(
                  'My Cart (${cart.items.length})',
                  style: const TextStyle(fontSize: 18),
                ),
                centerTitle: true,
                elevation: 0,
                backgroundColor: Colors.white,
              ),
              body: cart.items.isEmpty
                  ? _buildEmptyCart(context)
                  : Column(
                      children: [
                        _buildCouponSection(cart),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: cart.items.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) => _buildCartItem(
                              context,
                              cart.items[index],
                              cartNotifier,
                            ),
                          ),
                        ),
                        _buildCheckoutSection(
                          context,
                          cart,
                          settings,
                          total,
                        ),
                      ],
                    ),
            );
          },
        );
      },
    );
  }

  Widget _buildCouponSection(CartModel cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Apply Coupon',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (appliedPromotion == null) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    decoration: InputDecoration(
                      hintText: 'Enter coupon code',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: isLoadingCoupon
                      ? null
                      : () => _applyCoupon(context, cart),
                  child: isLoadingCoupon
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Apply'),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appliedPromotion!.title,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Discount: \$${_calculateDiscount(cart).toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: _removeCoupon,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(
    BuildContext context,
    CartModel cart,
    TaxAndDeliveryModel settings,
    double total,
  ) {
    double discountAmount = _calculateDiscount(cart);
    double serviceCharge =
        settings.toggleServiceCharge ? settings.serviceChargeAmount : 0.0;
    double deliveryFee = settings.toggleDelivery &&
            (settings.deliveryFeeNotApplyIfCartValueGreaterThan == null ||
                cart.subtotal <
                    settings.deliveryFeeNotApplyIfCartValueGreaterThan!)
        ? settings.deliveryFee
        : 0.0;
    double taxableAmount = serviceCharge + deliveryFee;
    double tax = settings.toggleTax
        ? taxableAmount * (settings.taxPercentage / 100)
        : 0.0;
    double finalTotal = total - discountAmount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPriceRow('Subtotal', cart.subtotal),
            if (settings.toggleServiceCharge) ...[
              const SizedBox(height: 8),
              _buildPriceRow('Service Charge', serviceCharge),
            ],
            if (settings.toggleDelivery) ...[
              const SizedBox(height: 8),
              _buildPriceRow('Delivery Fee', deliveryFee),
            ],
            if (settings.toggleTax) ...[
              const SizedBox(height: 8),
              _buildPriceRow(
                  'Tax (${settings.taxPercentage.toStringAsFixed(1)}%)', tax),
            ],
            if (discountAmount > 0) ...[
              const SizedBox(height: 8),
              _buildPriceRow('Discount', discountAmount, isDiscount: true),
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            _buildPriceRow('Total', finalTotal, isTotal: true),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.to(() => CheckoutPage(
                      taxAndDeliverySettings: settings,
                      appliedPromotion: appliedPromotion,
                      discountAmount: discountAmount,
                    )),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Proceed to Checkout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount,
      {bool isTotal = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.black : Colors.grey[600],
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          isDiscount
              ? '-\$${amount.toStringAsFixed(2)}'
              : '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: isDiscount
                ? Colors.green[700]
                : isTotal
                    ? Colors.green[700]
                    : Colors.black,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
    BuildContext context,
    CartItemModel item,
    CartNotifier cartNotifier,
  ) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16.0),
        decoration: BoxDecoration(
          color: Colors.red[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.delete_outline,
          color: Colors.red[700],
        ),
      ),
      onDismissed: (direction) {
        cartNotifier.removeFromCart(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.product.name} removed from cart'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                cartNotifier.addToCart(item.product, quantity: item.quantity);
              },
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: item.product.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.error_outline, color: Colors.grey[400]),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${item.price.toStringAsFixed(2)} each',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildQuantityButton(
                    Icons.remove,
                    () =>
                        cartNotifier.updateQuantity(item.id, item.quantity - 1),
                  ),
                  Container(
                    width: 32,
                    alignment: Alignment.center,
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildQuantityButton(
                    Icons.add,
                    () =>
                        cartNotifier.updateQuantity(item.id, item.quantity + 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        color: Colors.grey[700],
      ),
    );
  }
}
