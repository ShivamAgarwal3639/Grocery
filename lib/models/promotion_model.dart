import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PromotionModel {
  final String id;
  final String discount;
  final String title;
  final String subtitle;
  final String color1;
  final String color2;
  final String assetPath;
  final bool isActive;
  final DateTime startDate;
  final DateTime endDate;
  final int displayOrder;
  // New fields
  final bool isCoupon; // true for discount coupon, false for promotional banner
  final String discountType; // 'PERCENTAGE' or 'FLAT'
  final double discountValue; // Percentage or flat amount
  final double minOrderValue; // Minimum cart value required
  final double maxDiscountAmount; // Maximum discount limit (for percentage discounts)

  PromotionModel({
    required this.id,
    required this.discount,
    required this.title,
    required this.subtitle,
    required this.color1,
    required this.color2,
    required this.assetPath,
    required this.isActive,
    required this.startDate,
    required this.endDate,
    required this.displayOrder,
    required this.isCoupon,
    required this.discountType,
    required this.discountValue,
    required this.minOrderValue,
    required this.maxDiscountAmount,
  });

  // Convert Firestore data to PromotionModel
  factory PromotionModel.fromFirestore(Map<String, dynamic> data, String id) {
    return PromotionModel(
      id: id,
      discount: data['discount'] ?? '',
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      color1: data['color1'] ?? '',
      color2: data['color2'] ?? '',
      assetPath: data['assetPath'] ?? '',
      isActive: data['isActive'] ?? false,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      displayOrder: data['displayOrder'] ?? 0,
      isCoupon: data['isCoupon'] ?? false,
      discountType: data['discountType'] ?? 'PERCENTAGE',
      discountValue: (data['discountValue'] ?? 0).toDouble(),
      minOrderValue: (data['minOrderValue'] ?? 0).toDouble(),
      maxDiscountAmount: (data['maxDiscountAmount'] ?? 0).toDouble(),
    );
  }

  // Convert PromotionModel to Firestore data
  Map<String, dynamic> toFirestore() {
    return {
      'discount': discount,
      'title': title,
      'subtitle': subtitle,
      'color1': color1,
      'color2': color2,
      'assetPath': assetPath,
      'isActive': isActive,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'displayOrder': displayOrder,
      'isCoupon': isCoupon,
      'discountType': discountType,
      'discountValue': discountValue,
      'minOrderValue': minOrderValue,
      'maxDiscountAmount': maxDiscountAmount,
    };
  }

  // Calculate discount amount for a given cart value
  double calculateDiscount(double cartValue) {
    if (!isCoupon || cartValue < minOrderValue) {
      return 0;
    }

    double calculatedDiscount;
    if (discountType == 'PERCENTAGE') {
      calculatedDiscount = (cartValue * discountValue) / 100;
      if (maxDiscountAmount > 0 && calculatedDiscount > maxDiscountAmount) {
        calculatedDiscount = maxDiscountAmount;
      }
    } else { // FLAT
      calculatedDiscount = discountValue;
    }

    return calculatedDiscount;
  }

  // Existing color conversion methods
  Color getColor1() {
    return Color(int.parse(color1.replaceAll('#', '0xFF')));
  }

  Color getColor2() {
    return Color(int.parse(color2.replaceAll('#', '0xFF')));
  }

  // Check if promotion is currently valid
  bool isCurrentlyValid() {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }
}