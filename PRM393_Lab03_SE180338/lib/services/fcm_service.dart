import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../models/notification_item.dart';
import 'firestore_service.dart';

class FCMService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> initialize(
    String? userId, {
    Function(String? screen)? onNotificationTap,
  }) async {
    if (kIsWeb) return;
    try {
      // Request permission on Android 13+ & iOS
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint(
        'User FCM granted permission: ${settings.authorizationStatus}',
      );

      // Get FCM token for sending notifications from Firebase Console
      String? token = await _fcm.getToken();
      debugPrint('Firebase FCM Token: $token');

      // Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('FCM Foreground Message: ${message.notification?.title}');
        _handleIncomingMessage(message, userId);
      });

      // App opened from background / terminated via notification tap
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('FCM Opened from Notification: ${message.data}');
        final screen = message.data['screen'] ?? 's01_home';
        if (onNotificationTap != null) {
          onNotificationTap(screen);
        }
      });
    } catch (e) {
      debugPrint('FCM init error (non-fatal): $e');
    }
  }

  Future<void> _handleIncomingMessage(
    RemoteMessage message,
    String? userId,
  ) async {
    if (userId == null) return;
    final item = NotificationItem(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'Nhắc nhở chi tiêu',
      body: message.notification?.body ?? 'Kiểm tra ngân sách hôm nay của bạn.',
      receivedAt: DateTime.now(),
      screenToOpen: message.data['screen'],
    );
    try {
      await _firestoreService.saveNotification(userId, item);
    } catch (e) {
      debugPrint('Failed to save notification: $e');
    }
  }

  /// Create a demo notification for local testing/simulation
  Future<void> simulateNotification(
    String userId, {
    required String title,
    required String body,
    String? screen,
  }) async {
    final item = NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      receivedAt: DateTime.now(),
      screenToOpen: screen,
    );
    await _firestoreService.saveNotification(userId, item);
  }
}
