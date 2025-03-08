import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:Super96Store/firebase/user_service.dart';
import 'package:Super96Store/models/user_model.dart';
import 'package:Super96Store/notifier/sms_service.dart';


class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  String? _phoneNumber;

  String? get phoneNumber => _phoneNumber;
  bool get isAuthenticated => _phoneNumber != null;

  Future<void> initialize() async {
    _phoneNumber = await AuthService.getStoredPhoneNumber();
    notifyListeners();
  }

  Future<bool> sendOTP(String phoneNumber) async {
    isLoading = true;
    notifyListeners();

    try {
      final responseData = await AuthService.sendOTP(phoneNumber);
      return responseData != null;
    } catch (e) {
      log('Error in sendOTP: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOTP(String otp, String phoneNumber) async {
    isLoading = true;
    notifyListeners();

    try {
      log('Attempting to verify OTP: $otp for phone: $phoneNumber');
      final success = await AuthService.verifyOTP(otp, phoneNumber);
      log('OTP verification result: $success');

      if (success) {
        _phoneNumber = phoneNumber;
        UserService userService = UserService();
        UserModel? userModel = await userService.getUser(phoneNumber);

        if (userModel == null) {
          userService.createUser(UserModel(
              id: phoneNumber,
              phoneNumber: phoneNumber,
              createdAt: DateTime.now()));
        }
      }
      return success;
    } catch (e) {
      log('Error in verifyOTP: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await AuthService.signOut();
    _phoneNumber = null;
    notifyListeners();
  }
}