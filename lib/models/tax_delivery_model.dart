class TaxAndDeliveryModel {
  final String id;
  final bool toggleTax;
  final double taxPercentage;
  final bool toggleDelivery;
  final double deliveryFee;
  final double? deliveryFeeNotApplyIfCartValueGreaterThan;
  final bool toggleServiceCharge;
  final double serviceChargeAmount;
  final Map<String, double>? shopLocation;
  final double? deliveryDistance;
  final String? whatsappNumber;
  final String? openTime;  // Store time in 24-hour format HH:mm
  final String? closeTime; // Store time in 24-hour format HH:mm

  TaxAndDeliveryModel({
    required this.id,
    this.toggleTax = false,
    this.taxPercentage = 0.0,
    this.toggleDelivery = false,
    this.deliveryFee = 0.0,
    this.deliveryFeeNotApplyIfCartValueGreaterThan,
    this.toggleServiceCharge = false,
    this.serviceChargeAmount = 0.0,
    this.shopLocation,
    this.deliveryDistance,
    this.whatsappNumber,
    this.openTime,
    this.closeTime,
  });

  factory TaxAndDeliveryModel.fromMap(Map<String, dynamic> map) {
    return TaxAndDeliveryModel(
      id: map['id']?.toString() ?? '',
      toggleTax: map['toggleTax'] ?? false,
      taxPercentage: (map['taxPercentage'] ?? 0.0).toDouble(),
      toggleDelivery: map['toggleDelivery'] ?? false,
      deliveryFee: (map['deliveryFee'] ?? 0.0).toDouble(),
      deliveryFeeNotApplyIfCartValueGreaterThan:
      map['deliveryFeeNotApplyIfCartValueGreaterThan']?.toDouble(),
      toggleServiceCharge: map['toggleServiceCharge'] ?? false,
      serviceChargeAmount: (map['serviceChargeAmount'] ?? 0.0).toDouble(),
      shopLocation: map['shopLocation'] != null
          ? Map<String, double>.from(map['shopLocation'])
          : null,
      deliveryDistance: map['deliveryDistance']?.toDouble(),
      whatsappNumber: map['whatsappNumber']?.toString(),
      openTime: map['openTime']?.toString(),
      closeTime: map['closeTime']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'toggleTax': toggleTax,
      'taxPercentage': taxPercentage,
      'toggleDelivery': toggleDelivery,
      'deliveryFee': deliveryFee,
      'deliveryFeeNotApplyIfCartValueGreaterThan':
      deliveryFeeNotApplyIfCartValueGreaterThan,
      'toggleServiceCharge': toggleServiceCharge,
      'serviceChargeAmount': serviceChargeAmount,
      'shopLocation': shopLocation,
      'deliveryDistance': deliveryDistance,
      'whatsappNumber': whatsappNumber,
      'openTime': openTime,
      'closeTime': closeTime,
    };
  }

  TaxAndDeliveryModel copyWith({
    String? id,
    bool? toggleTax,
    double? taxPercentage,
    bool? toggleDelivery,
    double? deliveryFee,
    double? deliveryFeeNotApplyIfCartValueGreaterThan,
    bool? toggleServiceCharge,
    double? serviceChargeAmount,
    Map<String, double>? shopLocation,
    double? deliveryDistance,
    String? whatsappNumber,
    String? openTime,
    String? closeTime,
  }) {
    return TaxAndDeliveryModel(
      id: id ?? this.id,
      toggleTax: toggleTax ?? this.toggleTax,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      toggleDelivery: toggleDelivery ?? this.toggleDelivery,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      deliveryFeeNotApplyIfCartValueGreaterThan:
      deliveryFeeNotApplyIfCartValueGreaterThan ??
          this.deliveryFeeNotApplyIfCartValueGreaterThan,
      toggleServiceCharge: toggleServiceCharge ?? this.toggleServiceCharge,
      serviceChargeAmount: serviceChargeAmount ?? this.serviceChargeAmount,
      shopLocation: shopLocation ?? this.shopLocation,
      deliveryDistance: deliveryDistance ?? this.deliveryDistance,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
    );
  }
}