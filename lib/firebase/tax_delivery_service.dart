import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tax_delivery_model.dart';

class TaxAndDeliveryService {
  final CollectionReference _taxDeliveryCollection =
  FirebaseFirestore.instance.collection('taxAndDelivery');

  // Create or update tax and delivery settings
  Future<void> saveTaxAndDelivery(TaxAndDeliveryModel settings) async {
    try {
      await _taxDeliveryCollection.doc(settings.id).set(settings.toMap());
    } catch (e) {
      throw Exception('Failed to save tax and delivery settings: $e');
    }
  }

  // Get tax and delivery settings
  Future<TaxAndDeliveryModel?> getTaxAndDelivery(String id) async {
    try {
      final doc = await _taxDeliveryCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return TaxAndDeliveryModel.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get tax and delivery settings: $e');
    }
  }

  // Stream tax and delivery settings
  Stream<TaxAndDeliveryModel?> streamTaxAndDelivery(String id) {
    return _taxDeliveryCollection.doc(id).snapshots().map((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return TaxAndDeliveryModel.fromMap(data);
      }
      return null;
    });
  }

  // Calculate final charges
  double calculateTotalCharges({
    required double cartValue,
    required TaxAndDeliveryModel settings,
  }) {
    double total = cartValue;
    double taxableAmount = 0;

    // Add service charge if enabled
    if (settings.toggleServiceCharge) {
      taxableAmount += settings.serviceChargeAmount;
      total += settings.serviceChargeAmount;
    }

    // Add delivery fee if enabled
    if (settings.toggleDelivery) {
      // Check if delivery fee should be applied
      if (settings.deliveryFeeNotApplyIfCartValueGreaterThan == null ||
          cartValue < settings.deliveryFeeNotApplyIfCartValueGreaterThan!) {
        taxableAmount += settings.deliveryFee;
        total += settings.deliveryFee;
      }
    }

    // Add tax if enabled
    if (settings.toggleTax) {
      double taxAmount = taxableAmount * (settings.taxPercentage / 100);
      total += taxAmount;
    }

    return total;
  }
}