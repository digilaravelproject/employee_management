// Corrected NotificationHandlerService implementation for Attendance Tracking App.
// Handles foreground notifications with image (big picture) and background/killed notifications with text only.

import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class NotificationHandlerService {
  // Singleton pattern
  static final NotificationHandlerService _instance = NotificationHandlerService._();
  factory NotificationHandlerService() => _instance;
  NotificationHandlerService._();

  // Firebase Messaging instance
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // Local notifications plugin
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Channel constants
  static const String _channelId = 'fcm_channel';
  static const String _channelName = 'FCM Notifications';
  static const String _channelDesc = 'Channel for FCM data‑only notifications';

  // UI readiness flag – true after first frame (or when you call markAppReady()).
  static bool isAppReady = false;

  // Holds a payload that arrived before UI was ready.
  static Map<String, dynamic>? pendingPayload;

  // -------------------------------------------------------
  // Initialization – call from main() before runApp()
  Future<void> init() async {
    // Request permissions (iOS only; Android granted by default).
    await _fcm.requestPermission();

    // Initialize local notifications.
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const IOSInitializationSettings iosInit = IOSInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _localNotifications.initialize(initSettings, onSelectNotification: _onSelectNotification);

    // Create Android channel.
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Foreground message listener.
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    // When user taps a notification and opens app.
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);
  }

  // -------------------------------------------------------
  // Public method – call from UI when it becomes ready (e.g., after first frame).
  void markAppReady() {
    isAppReady = true;
    if (pendingPayload != null) {
      _showForegroundNotification(pendingPayload!);
      pendingPayload = null;
    }
  }

  // -------------------------------------------------------
  // Background handler – register in firebase_messaging background entry point.
  // This method will be invoked by the plugin in the background isolate.
  Future<void> showBackgroundNotification(Map<String, dynamic> payload) async {
    await _showSimpleTextNotification(payload);
  }

  // -------------------------------------------------------
  // Internal helpers
  void _handleForegroundMessage(RemoteMessage message) {
    final data = _extractData(message);
    if (isAppReady) {
      _showForegroundNotification(data);
    } else {
      pendingPayload = data;
    }
  }

  void _handleMessageOpened(RemoteMessage message) {
    final data = _extractData(message);
    final String? url = data['action_url'] as String?;
    if (url != null && url.isNotEmpty) {
      Get.toNamed(url);
    }
  }

  static Map<String, dynamic> _extractData(RemoteMessage message) {
    // Prefer data payload; ignore the notification part.
    return Map<String, dynamic>.from(message.data);
  }

  // Foreground – image if present.
  Future<void> _showForegroundNotification(Map<String, dynamic> payload) async {
    final String title = payload['title']?.toString() ?? 'Notification';
    final String body = payload['body']?.toString() ?? '';
    final String? imageUrl = payload['image_url']?.toString() ?? payload['image']?.toString();

    if (imageUrl != null && imageUrl.isNotEmpty) {
      // Download image, then show big‑picture style.
      final String filePath = await _downloadImage(imageUrl);
      final bigPicture = BigPictureStyleInformation(
        FilePathAndroidBitmap(filePath),
        largeIcon: FilePathAndroidBitmap(filePath),
        contentTitle: title,
        summaryText: body,
      );
      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        styleInformation: bigPicture,
        priority: Priority.high,
        importance: Importance.high,
      );
      final iosDetails = IOSNotificationDetails();
      final details = NotificationDetails(android: androidDetails, iOS: iosDetails);
      await _localNotifications.show(0, title, body, details, payload: payload['id']?.toString());
    } else {
      // No image – fallback to simple text.
      await _showSimpleTextNotification(payload);
    }
  }

  // Simple text‑only notification (used for background/killed and fallback).
  Future<void> _showSimpleTextNotification(Map<String, dynamic> payload) async {
    final String title = payload['title']?.toString() ?? 'Notification';
    final String body = payload['body']?.toString() ?? '';
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      priority: Priority.high,
      importance: Importance.high,
    );
    final iosDetails = IOSNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _localNotifications.show(0, title, body, details, payload: payload['id']?.toString());
  }

  // Download image to app's documents directory.
  Future<String> _downloadImage(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Image download failed (status ${response.statusCode})');
    }
    final Uint8List bytes = response.bodyBytes;
    final Directory dir = await getApplicationDocumentsDirectory();
    final String path = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.png';
    final File file = File(path);
    await file.writeAsBytes(bytes);
    return path;
  }

  // Notification tap callback.
  Future<void> _onSelectNotification(String? payload) async {
    if (payload == null) return;
    print('Notification tapped with payload: $payload');
  }
}
