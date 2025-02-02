import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class Utility{
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> _updateUserFCMToken(String userId) async {
    try {
      // Get the current FCM token
      String? token = await _messaging.getToken();

      if (token != null) {
        // Update the token in Firestore
        await _firestore.collection('users').doc(userId).update({
          'fcmTokens': token,
        });
      }
    } catch (e) {
      debugPrint('Error updating FCM token: $e');
    }
  }

  static i(){
    // Set up auth state listener
    _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        // User is signed in, update their FCM token
        await _updateUserFCMToken(user.uid);
      }
    });

    // Handle FCM token refresh
    _messaging.onTokenRefresh.listen((String token) async {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmTokens': token,
        });
      }
    });
  }
}