import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'in_app_notification_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init({BuildContext? context}) async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    // ✅ Request permission secara manual (aman untuk semua Android)
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload == 'exam_result') {
          debugPrint("➡️ Notifikasi diklik: exam_result");
            if (context != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Kamu membuka hasil ujian dari notifikasi!'),
                backgroundColor: const Color(0xFFFFC38D),
              ),
            );
          }
        }
      },
    );
  }

  static Future<void> show(String title, String body, {String? payload}) async {
    // Respect user's setting for notifications. If disabled, do nothing.
    try {
      final prefs = await SharedPreferences.getInstance();
      final allowed = prefs.getBool('allow_notifications') ?? true;
      if (!allowed) return;
    } catch (_) {
      // ignore and fall through to show notification if prefs fail
    }
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'main_channel',
        'Ejamate Notifications',
        channelDescription: 'Notifikasi ujian dan pembelajaran',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
    // Also persist an in-app notification so the app can show an unread badge/history
    try {
      await InAppNotificationService.add(title, body);
    } catch (_) {}
  }
}
