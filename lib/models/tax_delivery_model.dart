class TaxAndDeliveryModel {
  final String id;
  final bool toggleTax;
  final double taxPercentage;
  final bool toggleDelivery;
  final double deliveryFee;
  final double? deliveryFeeNotApplyIfCartValueGreaterThan;
  final bool toggleServiceCharge;
  final double serviceChargeAmount;
  final Map<String, double>? deliveryCordinate;
  final double? deliveryDistance;
  final String? whatsappNumber; // Add new field

  TaxAndDeliveryModel({
    required this.id,
    this.toggleTax = false,
    this.taxPercentage = 0.0,
    this.toggleDelivery = false,
    this.deliveryFee = 0.0,
    this.deliveryFeeNotApplyIfCartValueGreaterThan,
    this.toggleServiceCharge = false,
    this.serviceChargeAmount = 0.0,
    this.deliveryCordinate,
    this.deliveryDistance,
    this.whatsappNumber, // Add to constructor
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
      deliveryCordinate: map['deliveryCordinate'] != null
          ? Map<String, double>.from(map['deliveryCordinate'])
          : null,
      deliveryDistance: map['deliveryDistance']?.toDouble(),
      whatsappNumber: map['whatsappNumber']?.toString(),
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
      'deliveryCordinate': deliveryCordinate,
      'deliveryDistance': deliveryDistance,
      'whatsappNumber': whatsappNumber,
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
    Map<String, double>? deliveryCordinate,
    double? deliveryDistance,
    String? whatsappNumber, // Add to copyWith
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
      deliveryCordinate: deliveryCordinate ?? this.deliveryCordinate,
      deliveryDistance: deliveryDistance ?? this.deliveryDistance,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
    );
  }
}