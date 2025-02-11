import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:grocerry/notifier/auth_provider.dart';
import 'package:provider/provider.dart';

class Utility {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> _updateUserFCMToken(String phoneNumber) async {
    try {
      // Get the current FCM token
      String? token = await _messaging.getToken();

      if (token != null) {
        // Update the token in Firestore using phone number as document ID
        await _firestore.collection('users').doc(phoneNumber).update({
          'fcmTokens': token,
        });
      }
    } catch (e) {
      debugPrint('Error updating FCM token: $e');
    }
  }

  static void initialize(BuildContext context) {
    // Get AuthProvider instance
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Listen to authentication state changes
    authProvider.addListener(() {
      if (authProvider.isAuthenticated && authProvider.phoneNumber != null) {
        // User is authenticated, update their FCM token
        _updateUserFCMToken(authProvider.phoneNumber!);
      }
    });

    // Handle FCM token refresh
    _messaging.onTokenRefresh.listen((String token) async {
      if (authProvider.isAuthenticated && authProvider.phoneNumber != null) {
        await _firestore.collection('users').doc(authProvider.phoneNumber!).update({
          'fcmTokens': token,
        });
      }
    });
  }
}