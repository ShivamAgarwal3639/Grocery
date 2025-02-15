import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:Super96Store/firebase/notification/notification_service.dart';
import 'package:url_launcher/url_launcher.dart';

class FCMService {
  Future<String?> getInstanceId() async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    return await firebaseMessaging.getToken();
  }

  initializeFCM() {
    listenFcmNotificatoinAndUseAwesoneNotificationToShow();
    Future.delayed(const Duration(milliseconds: 10000), () {
      handleTerminatedAppNotification();
    });
  }

  listenFcmNotificatoinAndUseAwesoneNotificationToShow() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // Handle notification when app is in foreground
      if (message.notification != null) {
        await NotificationService.showNotification(
          title: message.notification?.title ?? '',
          body: message.notification?.body ?? '',
          payload: {
            'url': message.data['url'] ?? '',
            // Add any other data you want to pass
          },
        );
      }
      // Handle data message
      else if (message.data.isNotEmpty) {
        await NotificationService.showNotification(
          title: message.data['title'] ?? '',
          body: message.data['body'] ?? '',
          payload: {'url': message.data['url'] ?? ''},
        );
      }
    });

    // Handle notification tap when the app is in background or terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['url'] != null) {
      }
    });
  }

  Future<void> handleTerminatedAppNotification() async {
    // Check if the app was opened from a terminated state via a notification
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      // This means the app was opened from a terminated state by a notification
    }
  }

  requestNotificationPermission() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    log('User granted permission: ${settings.authorizationStatus}');
  }
}
