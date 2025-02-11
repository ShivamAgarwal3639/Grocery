import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

class AuthService {
  static const String _baseUrl = 'https://www.fast2sms.com/dev/bulkV2';
  static const String _authKey = 'YDFVdicuTZNfHqgxBmwsRXL96eSJ4zktWnyaQpKA8orC7I3l12DA9gXs6OQVkl8zRiGyjmEa3b01SHe4';
  static const _storage = FlutterSecureStorage();

  static String _generateOTP() {
    Random random = Random();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  static Future<String?> sendOTP(String phoneNumber) async {
    try {
      final otp = _generateOTP();

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'authorization': _authKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'route': 'otp',
          'variables_values': otp,
          'numbers': phoneNumber,
        }),
      );

      dev.log("_-------------------------------${response.body}");

      if (response.statusCode == 200) {
        await _storage.write(key: 'pending_otp', value: otp);
        return otp;
      }
      return null;
    } catch (e) {
      print('Error sending OTP: $e');
      return null;
    }
  }

  static Future<bool> verifyOTP(String userOTP, String phoneNumber) async {
    try {
      final storedOTP = await _storage.read(key: 'pending_otp');
      if (storedOTP == userOTP) {
        await _storage.delete(key: 'pending_otp');
        await _storage.write(key: 'phone_number', value: phoneNumber);
        return true;
      }
      return false;
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }

  static Future<String?> getStoredPhoneNumber() async {
    return await _storage.read(key: 'phone_number');
  }

  static Future<void> signOut() async {
    await _storage.delete(key: 'phone_number');
  }
}