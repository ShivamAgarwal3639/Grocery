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
    };
  }

  // Convert hex color string to Color object
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