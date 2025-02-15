// cart_button.dart
import 'package:flutter/material.dart';
import 'package:Super96Store/notifier/cart_notifier.dart';
import 'package:provider/provider.dart';
import 'package:Super96Store/models/product_model.dart';

class AddToCartButton extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onPressed;

  const AddToCartButton({
    super.key,
    required this.product,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.read<CartNotifier>().addToCart(product);
            onPressed?.call();
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QuantityControl extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  final bool mini;

  const QuantityControl({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(mini ? 4 : 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(mini ? 8 : 12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(
            icon: Icons.remove_rounded,
            onPressed: quantity > 1
                ? () => onChanged(quantity - 1)
                : null,
            mini: mini,
          ),
          SizedBox(width: mini ? 8 : 16),
          Text(
            quantity.toString(),
            style: TextStyle(
              fontSize: mini ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: mini ? 8 : 16),
          _buildButton(
            icon: Icons.add_rounded,
            onPressed: () => onChanged(quantity + 1),
            mini: mini,
            isAdd: true,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    VoidCallback? onPressed,
    required bool mini,
    bool isAdd = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(mini ? 6 : 8),
        child: Container(
          padding: EdgeInsets.all(mini ? 4 : 8),
          decoration: BoxDecoration(
            color: onPressed == null
                ? Colors.grey.shade200
                : isAdd
                ? Colors.green.shade50
                : Colors.red.shade50,
            borderRadius: BorderRadius.circular(mini ? 6 : 8),
          ),
          child: Icon(
            icon,
            size: mini ? 16 : 20,
            color: onPressed == null
                ? Colors.grey.shade400
                : isAdd
                ? Colors.green
                : Colors.red,
          ),
        ),
      ),
    );
  }
}