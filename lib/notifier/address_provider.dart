// address_provider.dart
import 'package:flutter/material.dart';
import 'package:grocerry/firebase/user_service.dart';
import '../models/user_model.dart';

class AddressProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  List<AddressModel> _addresses = [];
  bool _isLoading = false;
  String? _error;

  List<AddressModel> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAddresses(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await _userService.getUser(userId);
      _addresses = user?.addresses ?? [];

    } catch (e) {
      _error = 'Failed to load addresses: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAddress(String userId, AddressModel address) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _userService.addAddress(userId, address);
      await loadAddresses(userId);

    } catch (e) {
      _error = 'Failed to add address: $e';
      notifyListeners();
    }
  }

  Future<void> updateAddress(String userId, AddressModel address) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _userService.updateAddress(userId, address);
      await loadAddresses(userId);

    } catch (e) {
      _error = 'Failed to update address: $e';
      notifyListeners();
    }
  }

  Future<void> deleteAddress(String userId, String addressId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _userService.removeAddress(userId, addressId);
      await loadAddresses(userId);

    } catch (e) {
      _error = 'Failed to delete address: $e';
      notifyListeners();
    }
  }

  Future<void> setDefaultAddress(String userId, String addressId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _userService.setDefaultAddress(userId, addressId);
      await loadAddresses(userId);

    } catch (e) {
      _error = 'Failed to set default address: $e';
      notifyListeners();
    }
  }
}