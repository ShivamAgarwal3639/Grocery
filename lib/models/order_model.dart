import 'package:grocerry/models/cart_model.dart';
import 'package:grocerry/models/user_model.dart';
import 'package:grocerry/models/tax_delivery_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<CartItemModel> items;
  final double subtotal;
  final double serviceCharge;
  final double deliveryFee;
  final double tax;
  final double total;
  final OrderStatus status;
  final AddressModel shippingAddress;
  final AddressModel? billingAddress;
  final String? trackingNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;
  final TaxAndDeliveryModel taxAndDeliverySettings;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.serviceCharge,
    required this.deliveryFee,
    required this.tax,
    required this.total,
    this.status = OrderStatus.pending,
    required this.shippingAddress,
    this.billingAddress,
    this.trackingNumber,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    required this.taxAndDeliverySettings,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      items: List<CartItemModel>.from(
        (map['items'] ?? []).map((x) => CartItemModel.fromMap(x)),
      ),
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      serviceCharge: (map['serviceCharge'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (map['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      tax: (map['tax'] as num?)?.toDouble() ?? 0.0,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] != null
          ? OrderStatus.values.firstWhere(
            (e) => e.toString() == 'OrderStatus.${map['status']}',
        orElse: () => OrderStatus.pending,
      )
          : OrderStatus.pending,
      shippingAddress: AddressModel.fromMap(map['shippingAddress'] ?? {}),
      billingAddress: map['billingAddress'] != null
          ? AddressModel.fromMap(map['billingAddress'])
          : null,
      trackingNumber: map['trackingNumber']?.toString(),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'].toString())
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'].toString())
          : DateTime.now(),
      notes: map['notes']?.toString(),
      taxAndDeliverySettings: TaxAndDeliveryModel.fromMap(
          map['taxAndDeliverySettings'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((x) => x.toMap()).toList(),
      'subtotal': subtotal,
      'serviceCharge': serviceCharge,
      'deliveryFee': deliveryFee,
      'tax': tax,
      'total': total,
      'status': status.toString().split('.').last,
      'shippingAddress': shippingAddress.toMap(),
      'billingAddress': billingAddress?.toMap(),
      'trackingNumber': trackingNumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'notes': notes,
      'taxAndDeliverySettings': taxAndDeliverySettings.toMap(),
    };
  }
}
