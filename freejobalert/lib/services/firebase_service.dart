import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import '../screens/job_detail_screen.dart';
import '../utils/app_logger.dart';

class FirebaseService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static bool _isInitialized = false;

  // Initialize Firebase Messaging
  static Future<void> initialize() async {
    // Prevent multiple initializations
    if (_isInitialized) {
      AppLogger.info('Firebase Messaging already initialized');
      return;
    }

    try {
      // Request permission for notifications
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        AppLogger.firebase('User granted notification permission');
      } else {
        AppLogger.warning('User declined notification permission');
      }

      // Get FCM token
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        AppLogger.firebase('FCM Token obtained');
        // TODO: Send this token to your backend server
        await _sendTokenToServer(token);
      }

      // Listen to token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        AppLogger.firebase('FCM Token refreshed');
        _sendTokenToServer(newToken);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        AppLogger.firebase('Foreground message received: ${message.notification?.title}');
        _handleMessage(message);
      });

      // Handle notification clicks (when app is in background)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        AppLogger.firebase('Notification clicked (background)');
        _handleNotificationClick(message);
      });

      // Handle initial message (when app opens from terminated state)
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        AppLogger.firebase('App opened from notification (terminated state)');
        _handleNotificationClick(initialMessage);
      }

      // Mark as initialized
      _isInitialized = true;
      AppLogger.success('Firebase Messaging initialization complete');

    } catch (e) {
      AppLogger.error('Error initializing Firebase Messaging', e);
      _isInitialized = false;
    }
  }

  // Send token to your backend
  static Future<void> _sendTokenToServer(String token) async {
    try {
      final response = await http.post(
        Uri.parse('https://notifications.fresherslive.com/submit.php'),
        headers: {
          'User-Agent': 'FreeJobAlertApp/1.0',
          'Referer': 'https://www.freejobalert.com',
        },
        body: {
          'token': token,
          'website': 'freejobalertapp',
        },
      );

      if (response.statusCode == 200) {
        AppLogger.success('FCM token sent to server successfully');
      } else {
        AppLogger.warning('Failed to send token: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error sending token to server', e);
    }
  }

  // Handle incoming message
  static void _handleMessage(RemoteMessage message) {
    // Process foreground message
    AppLogger.firebase('Processing message', {
      'title': message.notification?.title,
      'body': message.notification?.body,
      'data': message.data,
    });

    // TODO: Show local notification or update UI
    // You can show a custom notification using flutter_local_notifications package
  }

  // Handle notification click
  static void _handleNotificationClick(RemoteMessage message) {
    AppLogger.firebase('Notification clicked', message.data);

    String? postId;
    String jobTitle = message.notification?.title ?? 'Job Details';

    // Check for postId directly
    if (message.data.containsKey('postId')) {
      postId = message.data['postId'];
    }
    // Extract postId from click_action URL (e.g., .../article-name-3028811)
    else if (message.data.containsKey('click_action')) {
      String url = message.data['click_action'];
      postId = _extractPostIdFromUrl(url);
    }

    if (postId != null && postId.isNotEmpty) {
      AppLogger.info('Opening job detail: $postId');
      _navigateToJobDetail(postId, jobTitle);
    } else {
      AppLogger.warning('No postId found in notification data');
    }
  }

  // Extract postId from URL (last number in the URL)
  static String? _extractPostIdFromUrl(String url) {
    try {
      // Match the last number in the URL (e.g., 3028811 from .../article-name-3028811)
      final regex = RegExp(r'-(\d+)$');
      final match = regex.firstMatch(url);
      if (match != null) {
        return match.group(1);
      }
    } catch (e) {
      AppLogger.error('Error extracting postId from URL', e);
    }
    return null;
  }

  // Navigate with retry to ensure navigator is ready
  static void _navigateToJobDetail(String postId, String jobTitle, [int retries = 0]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigatorKey.currentState != null) {
        navigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (context) => JobDetailScreen(
              postId: postId,
              jobTitle: jobTitle,
            ),
          ),
        );
        AppLogger.success('Navigated to job detail: $postId');
      } else if (retries < 10) {
        // Retry after delay if navigator not ready
        Future.delayed(const Duration(milliseconds: 300), () {
          _navigateToJobDetail(postId, jobTitle, retries + 1);
        });
      } else {
        AppLogger.error('Failed to navigate - navigator not ready after retries');
      }
    });
  }

  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      AppLogger.firebase('Subscribed to topic: $topic');
    } catch (e) {
      AppLogger.error('Error subscribing to topic: $topic', e);
    }
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      AppLogger.firebase('Unsubscribed from topic: $topic');
    } catch (e) {
      AppLogger.error('Error unsubscribing from topic: $topic', e);
    }
  }

  // Get FCM token
  static Future<String?> getToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      return token;
    } catch (e) {
      AppLogger.error('Error getting token', e);
      return null;
    }
  }

  // Delete FCM token
  static Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      AppLogger.firebase('FCM token deleted');
    } catch (e) {
      AppLogger.error('Error deleting token', e);
    }
  }

  // Check if notifications are authorized
  static Future<bool> isNotificationAuthorized() async {
    try {
      NotificationSettings settings = await _firebaseMessaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      AppLogger.error('Error checking notification authorization', e);
      return false;
    }
  }
}