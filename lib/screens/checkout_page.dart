import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grocerry/firebase/order_service.dart';
import 'package:grocerry/models/cart_model.dart';
import 'package:grocerry/models/order_model.dart';
import 'package:grocerry/models/promotion_model.dart';
import 'package:grocerry/models/user_model.dart';
import 'package:grocerry/models/tax_delivery_model.dart';
import 'package:grocerry/notifier/address_provider.dart';
import 'package:grocerry/notifier/cart_notifier.dart';
import 'package:grocerry/screens/profile/address_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class CheckoutPage extends StatefulWidget {
  final TaxAndDeliveryModel taxAndDeliverySettings;
  final PromotionModel? appliedPromotion;
  final double discountAmount;

  const CheckoutPage({
    super.key,
    required this.taxAndDeliverySettings,
    this.appliedPromotion,
    this.discountAmount = 0.0,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  AddressModel? selectedAddress;
  bool isProcessing = false;

  // Calculate charges based on current settings and applied promotion
  Map<String, double> calculateCharges(CartModel cart) {
    double subtotal = cart.subtotal;
    double serviceCharge = widget.taxAndDeliverySettings.toggleServiceCharge
        ? widget.taxAndDeliverySettings.serviceChargeAmount
        : 0.0;

    double deliveryFee = widget.taxAndDeliverySettings.toggleDelivery &&
            (widget.taxAndDeliverySettings
                        .deliveryFeeNotApplyIfCartValueGreaterThan ==
                    null ||
                subtotal <
                    widget.taxAndDeliverySettings
                        .deliveryFeeNotApplyIfCartValueGreaterThan!)
        ? widget.taxAndDeliverySettings.deliveryFee
        : 0.0;

    double taxableAmount = serviceCharge + deliveryFee;
    double tax = widget.taxAndDeliverySettings.toggleTax
        ? taxableAmount * (widget.taxAndDeliverySettings.taxPercentage / 100)
        : 0.0;

    double total =
        subtotal + serviceCharge + deliveryFee + tax - widget.discountAmount;

    return {
      'subtotal': subtotal,
      'serviceCharge': serviceCharge,
      'deliveryFee': deliveryFee,
      'tax': tax,
      'discount': widget.discountAmount,
      'total': total,
    };
  }

  Future<void> _placeOrder(BuildContext context) async {
    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a delivery address'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => isProcessing = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final cartNotifier = Provider.of<CartNotifier>(context, listen: false);
      final cart = cartNotifier.cart;
      final charges = calculateCharges(cart);

      final order = OrderModel(
        id: const Uuid().v4(),
        userId: user.uid,
        items: cart.items,
        subtotal: charges['subtotal']!,
        serviceCharge: charges['serviceCharge']!,
        deliveryFee: charges['deliveryFee']!,
        tax: charges['tax']!,
        total: charges['total']!,
        shippingAddress: selectedAddress!,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        taxAndDeliverySettings: widget.taxAndDeliverySettings,
        appliedPromotion: widget.appliedPromotion,
        discountAmount: widget.discountAmount,
      );

      final orderService = OrderService();
      await orderService.createOrder(order);
      await cartNotifier.clearCart();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => isProcessing = false);
    }
  }

  Widget _buildOrderSummary(Map<String, double> charges) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Subtotal', charges['subtotal']!),
            if (widget.taxAndDeliverySettings.toggleServiceCharge) ...[
              const SizedBox(height: 8),
              _buildSummaryRow('Service Charge', charges['serviceCharge']!),
            ],
            if (widget.taxAndDeliverySettings.toggleDelivery) ...[
              const SizedBox(height: 8),
              _buildSummaryRow('Delivery Fee', charges['deliveryFee']!),
            ],
            if (widget.taxAndDeliverySettings.toggleTax) ...[
              const SizedBox(height: 8),
              _buildSummaryRow(
                'Tax (${widget.taxAndDeliverySettings.taxPercentage}%)',
                charges['tax']!,
              ),
            ],
            if (widget.discountAmount > 0) ...[
              const SizedBox(height: 8),
              _buildSummaryRow('Discount', charges['discount']!,
                  isDiscount: true),
              if (widget.appliedPromotion != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Applied coupon: ${widget.appliedPromotion!.title}',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 12,
                  ),
                ),
              ],
            ],
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
            _buildSummaryRow('Total', charges['total']!, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount,
      {bool isTotal = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          isDiscount
              ? '-\$${amount.toStringAsFixed(2)}'
              : '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            fontSize: isTotal ? 16 : 14,
            color: isDiscount
                ? Colors.green[700]
                : isTotal
                    ? Theme.of(context).primaryColor
                    : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: Consumer2<AddressProvider, CartNotifier>(
        builder: (context, addressProvider, cartNotifier, child) {
          final cart = cartNotifier.cart;
          final charges = calculateCharges(cart);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildAddressSection(addressProvider),
                    const SizedBox(height: 24),
                    _buildPaymentSection(),
                    const SizedBox(height: 24),
                    _buildOrderSummary(charges),
                  ],
                ),
              ),
              _buildBottomBar(charges['total']!),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAddressSection(AddressProvider addressProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Delivery Address',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (addressProvider.addresses.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.location_off, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'No addresses found',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => Get.to(() => const AddressListPage()),
                      icon: const Icon(Icons.add),
                      label: const Text('Add New Address'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  ...addressProvider.addresses.map((address) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedAddress?.id == address.id
                                ? Theme.of(context).primaryColor
                                : Colors.grey.withOpacity(0.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: RadioListTile<AddressModel>(
                          value: address,
                          groupValue: selectedAddress,
                          title: Text(
                            address.label ?? 'Address',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${address.street}, ${address.city}\n${address.state}, ${address.postalCode}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          onChanged: (value) {
                            setState(() => selectedAddress = value);
                          },
                          selected: selectedAddress?.id == address.id,
                          activeColor: Theme.of(context).primaryColor,
                        ),
                      )),
                  TextButton.icon(
                    onPressed: () => Get.to(() => const AddressListPage()),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Another Address'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.payment, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Payment Method',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: RadioListTile(
                value: true,
                groupValue: true,
                title: const Text(
                  'Cash on Delivery',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Pay when you receive your order',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                onChanged: (value) {},
                activeColor: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FilledButton(
                onPressed: isProcessing ? null : () => _placeOrder(context),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Place Order',
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
}
