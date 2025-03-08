import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as dev;

class AuthService {
  static const String _baseUrlSend =
      'https://cpaas.messagecentral.com/verification/v3/send';
  static const String _baseUrlValidate =
      'https://cpaas.messagecentral.com/verification/v3/validateOtp';
  static const String _authToken =
      'eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJDLTBENjk4Q0FFRjkxNTQwQyIsImlhdCI6MTczOTY0NzQ3MCwiZXhwIjoxODk3MzI3NDcwfQ.y8b7-y9YNulE186IwBe2hLSUIrZ43vJXgRfbp3HWZozIdDWuIyjS9dx-dAOmU3vZ2A0y3V9Apdi0haPc9xyknA';
  static const String _customerId = 'C-0D698CAEF91540C';
  static const _storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>?> sendOTP(String phoneNumber) async {
    try {
      final String url =
          '$_baseUrlSend?countryCode=91&customerId=$_customerId&flowType=SMS&mobileNumber=$phoneNumber';

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'authToken': _authToken,
          'Content-Type': 'application/json',
        },
      );

      dev.log("OTP Send Response: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['responseCode'] == 200 &&
            responseData['message'] == 'SUCCESS') {
          // Store the verification ID for later validation
          final verificationId =
          responseData['data']['verificationId']; // ✅ Correct key
          dev.log("Storing verification ID: $verificationId");
          await _storage.write(
              key: 'verification_id', value: verificationId.toString());
          return responseData['data'];
        }
      }
      dev.log("Failed to send OTP: ${response.statusCode} - ${response.body}");
      return null;
    } catch (e) {
      dev.log('Error sending OTP: $e');
      return null;
    }
  }

  static Future<bool> verifyOTP(String userOTP, String phoneNumber) async {
    try {
      final verificationId = await _storage.read(key: 'verification_id');

      if (verificationId == null) {
        dev.log('Verification ID not found in storage');
        return false;
      }

      dev.log('Retrieved verification ID: $verificationId for validation');

      final String url =
          '$_baseUrlValidate?countryCode=91&mobileNumber=$phoneNumber&verificationId=$verificationId&customerId=$_customerId&code=$userOTP';

      dev.log("Validating OTP with URL: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'authToken': _authToken,
        },
      );

      dev.log("OTP Verify Response Status: ${response.statusCode}");
      dev.log("OTP Verify Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['responseCode'] == 200 &&
            responseData['message'] == 'SUCCESS' &&
            responseData['data']['verificationStatus'] ==
                'VERIFICATION_COMPLETED') {
          await _storage.delete(key: 'verification_id');
          await _storage.write(key: 'phone_number', value: phoneNumber);
          return true;
        }
        dev.log("Validation failed: ${responseData['message']}");
      } else {
        dev.log(
            "Validation error: ${response.reasonPhrase} - ${response.body}");
      }
      return false;
    } catch (e) {
      dev.log('Error verifying OTP: $e');
      return false;
    }
  }

  static Future<String?> getStoredPhoneNumber() async {
    return await _storage.read(key: 'phone_number');
  }

  static Future<void> signOut() async {
    await _storage.delete(key: 'phone_number');
    await _storage.delete(key: 'verification_id');
  }
}
