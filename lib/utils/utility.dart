import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:Super96Store/notifier/auth_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Utility {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static final customCacheManager = CacheManager(
    Config(
      'customImageCache',
      stalePeriod: Duration(days: 30), // Refresh after 24 hours
      maxNrOfCacheObjects: 450,
      repo: JsonCacheInfoRepository(databaseName: 'imageCache'),
      fileService: HttpFileService(),
    ),
  );

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

  static void logout(phoneNumber) async {
    await _firestore.collection('users').doc(phoneNumber).update({
      'fcmTokens': null,
    });
  }

  static void initialize(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.phoneNumber != null) {
      _updateUserFCMToken(authProvider.phoneNumber!);

      // Handle FCM token refresh
      _messaging.onTokenRefresh.listen((String token) async {
        if (authProvider.isAuthenticated && authProvider.phoneNumber != null) {
          await _firestore
              .collection('users')
              .doc(authProvider.phoneNumber!)
              .update({
            'fcmTokens': token,
          });
        }
      });
    }
  }
}
